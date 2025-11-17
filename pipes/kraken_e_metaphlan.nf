#!/usr/bin/env nextflow

include { KRAKEN_INITIALREPORT } from '../modules/nf-core/kraken2/kraken2/main'
include { METAPHLAN_METAPHLAN } from '../modules/nf-core/metaphlan/metaphlan/main'

workflow {
    fastq_ch = Channel.fromFilePairs("${params.kraken_metaphlan.input_fastq}/*/*_{1,2}.{fa,fastq,fastq.gz}")
    .map{meta, fastq->
    [[id: fastq[0].getParent().getName()], fastq]}.view()

    fa_ch = Channel.fromPath("${params.kraken_metaphlan.input_assembly}/*/*.{fa,fasta,fa.gz}")
    .map{fa->
    [[id: fa.getParent().getName()], fa]}.view()

    KRAKEN_INITIALREPORT (fastq_ch, params.kraken_metaphlan.kraken_db)
    METAPHLAN_METAPHLAN(fa_ch, params.kraken_metaphlan.metaphlan_db)
}

