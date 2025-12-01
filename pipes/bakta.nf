#!/usr/bin/env nextflow
params.scripyts_dir = "${moduleDir}/bin"

include { EGGNOGMAPPER } from '../modules/nf-core/eggnogmapper/main'
include { BAKTA_BAKTA } from '../modules/nf-core/bakta/bakta/main'

workflow {
    def bins_table = file(params.bakta.bins_table).text.split("\n").drop(1)

    fa_ch = Channel.from(bins_table).map { row ->
        def columns = row.split("\t")
        def file_name = columns[0]
        def sample_name = columns[-2]
        def id = "${sample_name}_${file_name.split("_")[0]}" 
        def path = "${params.bakta.fa_pattern}/${sample_name}/Final_bestbinset/${file_name}.fa"
        [[meta_id: sample_name, id: id.split("_")[1]], path]
    }//.view()

    arq_ch = Channel.fromPath(params.bakta.arq)
        .splitCsv(sep: '\t').map{row -> row[0]}
        .map{fa->
            def parts = fa.split("_")
            [[meta_id: parts[0], id: parts[1].split("_")[0]], "Archaea"]}
    bac_ch = Channel.fromPath(params.bakta.bac)
        .splitCsv(sep: '\t').map{row -> row[0]}
        .map{fa->
            def parts = fa.split("_")
            [[meta_id: parts[0], id: parts[1].split("_")[0]], "Bacteria"]}   
    

    geral_ch = arq_ch.concat(bac_ch).view()

    combined_ch = fa_ch.combine(geral_ch, by:0).map { meta, path, kingdom ->
        def new_meta = meta + [kingdom: kingdom]
        [new_meta, path]
    }//.view()

    annot_info = BAKTA_BAKTA(combined_ch, params.bakta.bakta_db, [], [])

    eggnog_info = EGGNOGMAPPER(annot_info.faa, [], params.bakta.eggnog_db, [[], []])
}