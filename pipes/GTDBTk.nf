#!/usr/bin/env nextflow

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
    stub:
    def new_name = "${meta.meta_id}_${fasta.getName()}"
    """
    touch ${new_name}
    """
}

workflow {
    fa_ch = Channel.fromPath("${params.gtdbtk.input}/assembly_0/*/Final_bestbinset/*.fa")
    .map{fa->
    [[meta_id: fa.getParent().getParent().getName(),
    id: fa.getName().split("_")[0]], fa]}.view()

    fasta_rn_ch = RENAME_FILES(fa_ch)

    fasta_sh = fasta_rn_ch.map{meta, fasta ->
        def new_meta = [id: 'Samples']
        [new_meta, fasta]}.groupTuple(by: 0)
    
    gtdb_path = file( "${params.gtdbtk.gtdbtk_db}", checkIfExists: true)
    
    gtdb_dir = gtdb_path.listFiles()
    
    ch_db_for_gtdbtk = Channel
                        .of(gtdb_dir)
                        .collect()
                        .map { ["gtdb", it] }
    
    gtdbtk_ch = GTDBTK_CLASSIFYWF(fasta_sh, ch_db_for_gtdbtk, [], [])
}
