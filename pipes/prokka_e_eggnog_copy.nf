#!/usr/bin/env nextflow

params.input = "" // /home/inaiag/Argentina/Results_basalt/temp
params.outdir = "" // /home/inaiag/Argentina/annotation
params.debug = false
params.arq = "/home/inaiag/Argentina/taxonomy/gtdbtk_2/gtdbtk.Samples.ar53.summary.tsv"
params.bac = "/home/inaiag/Argentina/taxonomy/gtdbtk_2/gtdbtk.Samples.bac120.summary.tsv"
params.scripts_dir = "${moduleDir}/bin"
params.eggnog_db = "/home/inaiag/Databases/EggNOG/eggnog-mapper/data"

// params.bins_table = "/home/inaiag/Argentina/final_bins.tsv"
params.bins_table = "/home/inaiag/Argentina/final_bins_copy.tsv"

params.fa_pattern = "${params.input}/assembly_0"

include { EGGNOGMAPPER } from '../modules/nf-core/eggnogmapper/main'
include { PROKKA } from '../modules/nf-core/prokka/main'

workflow {
    def bins_table = file(params.bins_table).text.split("\n").drop(1)
    
    fa_ch = Channel.from(bins_table).map { row ->
        def columns = row.split("\t")
        def file_name = columns[0]
        def sample_name = columns[-2]
        def id = "${sample_name}_${file_name.split("_")[0]}" 
        def path = "${params.fa_pattern}/${sample_name}/Final_bestbinset/${file_name}.fa"
        [[meta_id: sample_name, id: id.split("_")[1]], path]
    }.view()

    arq_ch = Channel.fromPath(params.arq)
        .splitCsv(sep: '\t').map{row -> row[0]}
        .map{fa->
            def parts = fa.split("_")
            [[meta_id: parts[0], id: parts[1].split("_")[0]], "Archaea"]}
    bac_ch = Channel.fromPath(params.bac)
        .splitCsv(sep: '\t').map{row -> row[0]}
        .map{fa->
            def parts = fa.split("_")
            [[meta_id: parts[0], id: parts[1].split("_")[0]], "Bacteria"]}   
    

    geral_ch = arq_ch.concat(bac_ch)//.view()

    combined_ch = fa_ch.combine(geral_ch, by:0).map { meta, path, kingdom ->
        def new_meta = meta + [kingdom: kingdom]
        [new_meta, path]
    }.view()

    annot_info = PROKKA(combined_ch, [], [])

    eggnog_info = EGGNOGMAPPER(annot_info.faa, [], params.eggnog_db, [[], []])
}

// command: nextflow run prokka_e_eggnog_copy.nf --input /home/inaiag/Argentina/Results_basalt/temp --outdir /home/inaiag/Argentina/annotation_filtered_stub -stub -profile stub
// command: nextflow run prokka_e_eggnog_copy.nf --input /home/inaiag/Argentina/Results_basalt/temp --outdir /home/inaiag/Argentina/annotation_filtered -resume -bg
