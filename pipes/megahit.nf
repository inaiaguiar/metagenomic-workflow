#!/usr/bin/env nextflow

params.input_fa = ""
params.outdir = ""

params.fa_pattern = "${params.input_fa}/*/*_{1,2}.fastq"

include { MEGAHIT } from '../modules/nf-core/megahit/main'

workflow {
    fa_ch = Channel.fromFilePairs(params.fa_pattern)
    .map{id,fa->[[id:id], fa[0], fa[1]]}.view()

    // fa_ch = Channel.fromFilePairs(params.fa_pattern)
    //     .map { id, fa -> tuple([id: id], fa[0], fa[1], "--min-contig-len 1000 --k-min 31 --k-max 151 --k-step 10") }

    
    MEGAHIT(fa_ch) 
}

// padrão: "--min-contig-len 1000 --k-min 21 --k-max 141 --k-step 20"
// command: 
// cd Argentina/metagenomic-workflow/pipes/
// nextflow run megahit.nf --input_fa /home/inaiag/Argentina/clean_reads_novas_amostras --outdir /home/inaiag/Argentina/Assembly_novas_amostras/ -resume
// Stub command:  nextflow run megahit.nf --input_fa /home/inaiag/Argentina/clean_reads_novas_amostras --outdir /home/inaiag/Argentina/Assembly_stub -stub -profile stub  