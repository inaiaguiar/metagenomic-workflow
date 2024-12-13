#!/usr/bin/env nextflow

params.input = "" // /home/inaiag/Argentina/Results_basalt
params.outdir = "" // /home/inaiag/Argentina/annotation
params.debug = false
params.arq = "/home/inaiag/Argentina/taxonomy/GTDBTk/gtdbtk.Samples.ar53.summary.tsv"
params.bac = "/home/inaiag/Argentina/taxonomy/GTDBTk/gtdbtk.Samples.bac120.summary.tsv"
params.scripts_dir = "${moduleDir}/bin"
params.eggnog_db = "/home/inaiag/Databases/EggNOG"


params.fa_pattern = "${params.input}/*/Final_bestbinset/*.fa"

include { EGGNOGMAPPER } from '../modules/nf-core/eggnogmapper/main'
include { PROKKA } from '../modules/nf-core/prokka/main'

// process RENAME_FILES {
//     input:
//     tuple val(meta), path(fasta)
//     output:
//     tuple val(meta), path("*.fa")
//     script:
//     """
//     mv ${fasta} ${meta.meta_id}_${meta.id}.fa
//     """
// } 

// process COPY_GENOMESCAN_FILES {

//     publishDir "${params.outdir}/${meta.meta_id}/GenomeScan_v2/${meta.id}", mode: 'copy'

//     input:
//     tuple val(meta), path(csv), path(xlsx)
//     output:
//     tuple val(meta), path('GenomeScan_v2/GenomeScan_genome_scan.csv')    , emit: csv
//     tuple val(meta), path('GenomeScan_v2/GenomeScan_genome_scan.xlsx')   , emit: xlsx
//     script:
//     """
//     mkdir -p GenomeScan_v2
//     cp ${csv} ${xlsx} GenomeScan_v2/
//     """
// }

workflow {
    fa_ch = Channel.fromPath(params.fa_pattern).map{fa->
    [[meta_id: fa.getParent().getParent().getName(),
    id: fa.getName().split("_")[0]], fa]}

    // fasta_rn_ch = RENAME_FILES(fa_ch)

    // fa_ch.count().view{"Channel size: $it"}

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

    geral_ch = arq_ch.concat(bac_ch)

    // combined_ch = fasta_rn_ch.combine(geral_ch, by:0).map{meta, fa, geral ->
    //     def new_meta = meta+[kingdom: geral]
    //     [new_meta, fa]}
    
    combined_ch = fa_ch.combine(geral_ch, by:0).map{meta, fa, geral ->
        def new_meta = meta+[kingdom: geral]
        [new_meta, fa]}.view()

    // combined_ch.count().view{"Channel size: $it"}

    annot_info = PROKKA(combined_ch, [], [])

    eggnog_info = EGGNOGMAPPER(annot_info.gbk, params.eggnog_db, [], [[], []])

    // copy_files = COPY_GENOMESCAN_FILES(genome_scan_info.csv.combine(genome_scan_info.xlsx, by:0))

}