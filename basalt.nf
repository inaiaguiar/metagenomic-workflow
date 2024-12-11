#!/usr/bin/env nextflow

params.input_assembly = ""
params.input_fastq = ""


params.fastq_pattern = "${params.input_fastq}/*/*_{1,2}.{fastq,fastq.gz}"
params.fa_pattern = "${params.input_assembly}/*/*.{fa,fasta}"

process BASALT {
    tag "${meta.id}" 
    debug true
    maxForks 4
    maxRetries 4
    errorStrategy { 
        task.attempt <= 3 ? 'retry' : 'ignore'
    }
    conda "/opt/anaconda3/envs/BASALT"
    publishDir "${params.outdir}/results/${meta.id}", mode: 'copy'

    input:
    tuple val(meta), path(fastq), path(assembly)
    output:
    tuple val(meta), path("*")
    script:
    """
    BASALT\
        -a ${assembly} \
        -s ${fastq[0]},${fastq[1]} \
        -t 64 -m 256
    """
    stub: 
    """
    mkdir result_stub_basalt
    cd result_stub_basalt
    touch result_test.txt
    """
}

workflow {
    fastq_ch = Channel.fromFilePairs(params.fastq_pattern).map{meta, fastq->
    [[id: fastq[0].getParent().getName()], fastq]}
    
    fa_ch = Channel.fromPath(params.fa_pattern).map{fa->
    [[id: fa.getParent().getName()], fa]}

    combined = fastq_ch.combine(fa_ch, by: 0).view()
    
    BASALT(combined)
}