#!/usr/bin/env nextflow

include { MEGAHIT } from '../modules/nf-core/megahit/main'

workflow {
    fa_ch = Channel.fromFilePairs("${params.input_fastq}/*/*_{1,2}.{fa,fastq,fastq.gz}")
    .map{id,fa->[[id:id], fa[0], fa[1]]}.view()

    MEGAHIT(fa_ch)
}