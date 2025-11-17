#!/usr/bin/env nextflow

include { BOWTIE2_ALIGN } from '../modules/nf-core/bowtie2/align/main'
include { BOWTIE_BUILD } from '../modules/nf-core/bowtie/build/main'                                    

workflow {    
    
    illumina_seqs = Channel.fromFilePairs("${params.remap.input_reads}/*/*_{1,2}.fastq")
        .map { id, files -> 
            tuple(id.replace('.unmapped', ''), files[0], files[1]) 
        }//.view()
    
    bins = Channel.fromPath("${params.remap.bins_fasta}/*/Final_bestbinset/*.fa")
        .map { bin -> tuple([id: bin.baseName], bin) }//.view()

    bowtie_index = BOWTIE_BUILD(bins)
        .index
        // .map { meta, index_files ->
        //     tuple(meta, index_files[0].parent)
        // .map { meta, index_files ->
        //     tuple(meta, index_files)
        //}

    bowtie_results = BOWTIE2_ALIGN(
        illumina_seqs,
        bowtie_index,
        Channel.empty(),
        Channel.value(true),  // save_unaligned
        Channel.value(true)    // sort_bam
    )
}