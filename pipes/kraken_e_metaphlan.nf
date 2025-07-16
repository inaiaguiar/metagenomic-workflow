#!/usr/bin/env nextflow

params.input_assembly = "/home/inaiag/Argentina/Assembly/"
params.input_fastq = "/home/inaiag/Argentina/clean_reads/"
params.outdir = ""
params.kraken_db = "/home/inaiag/Databases/Kraken2"
params.metaphlan_db = "/home/inaiag/Databases/MetaPhlAn"

params.fastq_pattern = "${params.input_fastq}/*/*_{1,2}.fastq"
params.fa_pattern = "${params.input_assembly}/*/*.{fa,fasta}"

include { KRAKEN2_KRAKEN2 } from '../modules/nf-core/kraken2/kraken2/main'
include { METAPHLAN_METAPHLAN } from '../modules/nf-core/metaphlan/metaphlan/main'

workflow {
    fastq_ch = Channel.fromFilePairs(params.fastq_pattern).map{meta, fastq->
    [[id: fastq[0].getParent().getName()], fastq]}.view()
    //.filter{
       // meta, fastq -> meta.id in ["RSR01","RSR02","RSR03","RSR04","RSR05","RSR06","RSR07","RSR08"]}

    fa_ch = Channel.fromPath(params.fa_pattern).map{fa->
    [[id: fa.getParent().getName()], fa]}.view()
    //.filter{
      //  meta, fa -> meta.id in ["RSR01","RSR02","RSR03","RSR04","RSR05","RSR06","RSR07","RSR08", "RSR14"]}
    
    KRAKEN2_KRAKEN2 (fastq_ch, params.kraken_db, Channel.value(false), Channel.value(false))
    METAPHLAN_METAPHLAN(fa_ch, params.metaphlan_db)
}

