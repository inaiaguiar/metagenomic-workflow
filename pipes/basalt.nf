#!/usr/bin/env nextflow

params.input_assembly = ""
params.input_fastq = ""
params.outdir = ""

params.fa_pattern = "${params.input_assembly}/*/*.{fa,fasta,fa.gz}"
params.fastq_pattern = "${params.input_fastq}/*/*_{1,2}.{fa,fastq,fastq.gz}"

process BASALT {
    tag "${meta.id}" 
    debug true
    conda "/home/inaiag/miniconda3/envs/basalt-env"
    publishDir "${params.outdir}/Results_basalt/${meta.id}", mode: 'copy'

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

// stub command: nextflow run basalt.nf --input_assembly /home/inaiag/Argentina/Assembly_na --input_fastq /home/inaiag/Argentina/novas_amostras --outdir /home/inaiag/Argentina -stub -profile stub
// command: nextflow run basalt.nf --input_assembly /home/inaiag/Argentina/Assembly_novas_amostras/assembly_2 --input_fastq /home/inaiag/Argentina/clean_reads_novas_amostras --outdir /home/inaiag/Argentina -resume


// Erros no script de execução do basalt:

// 1.
//   File "/home/inaiag/miniconda3/envs/basalt-env/bin/S6_retrieve_contigs_from_PE_contigs_checkm.py", line 1401, in parse_bin_in_bestbinset
//    os.chdir(str(binset)+'_retrieved_checkm/storage/')
//FileNotFoundError: [Errno 2] No such file or directory: 'BestBinset_outlier_refined_filtrated_retrieved_checkm/storage/'

// Resolução: Adicionar o comando mkdir para criar o diretório que está faltando: 
        // if int(last_step) < 7:
        // print('Comparing bins with retrieved bins')
        // target_dir = str(binset) + '_retrieved_checkm/storage/'

        // # Cria a pasta se ela não existir
        // os.makedirs(target_dir, exist_ok=True)
        // # Agora pode mudar para a pasta com segurança
        // os.chdir(target_dir)        
        
        // print('Parsing '+str(binset)+'_retrieved_checkm output')

// 2.   File "/home/inaiag/miniconda3/envs/basalt-env/bin/S7_Contigs_retrieve_within_group_checkm.py", line 1655, in Contig_retrieve_within_group
//    if level_num:
//UnboundLocalError: local variable 'level_num' referenced before assignment

// Resolução: Adicionar a variável level_num como global
        // level_num = None
        // for level_num in range(1, int(max_iteration)+1):
        //     if level_num > latest_iteration:
        //         if level_num == 1:
        //             print('Start form 1st iteration')
        //         else:
        //             print('Continue with iteration '+str(level_num))

        // E colocar na linha 1655:
        //  os.chdir(pwd)
        // if level_num:
        //     os.system('mv *_filtrated_bin_connecting_contigs_'+str(level_num)+'.txt *_eliminated_bin_connecting_contigs_'+str(level_num)+'.txt '+binset+'_retrieved_'+str(level_num))
        // os.system('rm -rf coverage_filtration_matrix_* TNF_filtration_matrix_*')