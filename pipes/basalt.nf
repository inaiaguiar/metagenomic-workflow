#!/usr/bin/env nextflow

process BASALT {
    tag "${meta.id}" 
    debug true
    conda params.basalt.conda
    publishDir "${params.basalt.outdir}/Results_basalt/${meta.id}", mode: 'copy'

    input:
    tuple val(meta), path(fastq), path(assembly)
    
    output:
    tuple val(meta), path("*")
    
    script:
    """
    BASALT \
        -a ${assembly} \
        -s ${fastq[0]},${fastq[1]} \
        -t 64 -m 256
    """
    
    stub: 
    """
    mkdir -p result_stub_basalt
    cd result_stub_basalt
    touch result_test_${meta.id}.txt
    """
}

workflow {
    fastq_ch = Channel
        .fromFilePairs("${params.input_fastq}/*/*_{1,2}.{fa,fastq,fastq.gz}")
        .map { meta, fastq ->
            [[id: fastq[0].getParent().getName()], fastq]
        }
    
    fa_ch = Channel
        .fromPath("${params.input_assembly}/*/*.{fa,fasta,fa.gz}")
        .map { fa ->
            [[id: fa.getParent().getName()], fa]
        }

    combined = fastq_ch.combine(fa_ch, by: 0).view()
    
    BASALT(combined)
}