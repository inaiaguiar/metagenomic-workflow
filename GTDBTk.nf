#!/usr/bin/env nextflow

params.input = "/Metagenomes/inaia/Results_basalt/"
params.outdir = "/Metagenomes/inaia/Results_taxonomy/GTDBTk_result"
params.debug = false

params.fa_pattern = "${params.input}/*/Final_bestbinset/*.fa"

include { GTDBTK_CLASSIFYWF } from '../modules/nf-core/gtdbtk/classifywf/main'

process RENAME_FILES {
    input:
    tuple val(meta), path(fasta)
    output:
    tuple val(meta), path("*.fa")
    script:
    """
    mv ${fasta} ${meta.meta_id}_${fasta}
    """
}

workflow {
    fa_ch = Channel.fromPath(params.fa_pattern).map{fa->
    [[meta_id: fa.getParent().getParent().getName(),
    id: fa.getName().split("_")[0]], fa]}

    fasta_rn_ch = RENAME_FILES(fa_ch)

    fasta_sh = fasta_rn_ch.map{meta, fasta ->
        def new_meta = [id: 'Samples']
        [new_meta, fasta]}.groupTuple(by: 0)
    
    gtdb_path = file( "${GTDBTK_DATA}", checkIfExists: true)
    
    gtdb_dir = gtdb_path.listFiles()
    
    ch_db_for_gtdbtk = Channel
                        .of(gtdb_dir)
                        .collect()
                        .map { ["gtdb", it] }
    
    gtdbtk_ch = GTDBTK_CLASSIFYWF(fasta_sh, ch_db_for_gtdbtk, [], [])
}