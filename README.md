# Metagenomic Workflow Pipeline

Pipeline em Nextflow para análise metagenômica completa, incluindo montagem, binning, taxonomia e anotação funcional.


## 📋 Visão Geral

Este repositório contém workflows Nextflow para processamento de dados metagenômicos, desde reads brutas até anotação funcional de bins. Os workflows são modulares e podem ser executados independentemente ou em sequência.


## 🗂️ Estrutura do Repositório

```
.
├── GTDBTk.nf                    # Classificação taxonômica com GTDB-Tk
├── bakta.nf                     # Anotação funcional com Bakta
├── basalt.nf                    # Binning com BASALT
├── kraken_e_metaphlan.nf        # Classificação taxonômica de reads e contigs
├── megahit.nf                   # Montagem de metagenomas
├── prokka_e_eggnog_copy.nf      # Anotação com Prokka e EggNOG
├── nextflow.config              # Configurações gerais do Nextflow
├── preset.config                # Perfis de execução
└── modules/                     # Módulos nf-core
└── params_exemple_config/       # Exemplo de params.config
└── tower_exemplo.config/        # Exemplo de tower.config

``` 



## 🔧 Configuração Inicial

### 1. Arquivos de Configuração Necessários
   
Você precisará criar dois arquivos de configuração local (não commitados no repositório):
Crie um arquivo params.config com seus caminhos específicos de acordo com params_exemple.config e um tower.config com a chave de monitoramento Seqera, de acordo com o tower_exemplo.config. 

### 2. Estrutura de Diretórios Esperada
   
Organize seus dados seguindo esta estrutura:
projeto/

``` 
├── clean_reads/              # Reads limpos após QC
│   ├── sample1/
│   │   ├── sample1_1.fastq.gz
│   │   └── sample1_2.fastq.gz
│   └── sample2/
│       ├── sample2_1.fastq.gz
│       └── sample2_2.fastq.gz
├── assemblies/               # Saída do MEGAHIT
├── bins/                     # Saída do BASALT
├── taxonomy/                 # Saída Kraken2/MetaPhlAn/GTDBTk
└── annotation/               # Saída Prokka/EggNOG/Bakta
```


## 🔄 Ordem de Execução do Pipeline

Execute os workflows nesta ordem para análise completa:


### 1️⃣ Assembly - MEGAHIT

- Montagem de metagenomas a partir de reads pareados.

- Saída: Contigs montados (final.contigs.fa) para cada amostra.

```
# Stub:
nextflow run megahit.nf --input_fastq /your/clean_reads/path --outdir /your/assembly_output_stub/path -stub -profile stub
# Commando:
nextflow run megahit.nf --input_fastq /your/clean_reads/path --outdir /your/assembly_output/path -resume -bg 
```
  

### 2️⃣ Binning - BASALT

- Criação de bins (MAGs) a partir dos contigs.

- Saída: Bins em Results_basalt/*/Final_bestbinset/*.fa

```
# Stub:
nextflow run basalt.nf --input_assembly /your/assembly/path --input_fastq /your/clean_reads/path --outdir /your/basalt_output/path -stub -profile stub
# Comando:
nextflow run basalt.nf --input_assembly /your/assembly/path --input_fastq /your/clean_reads/path --outdir /your/basalt_output/path -resume -bg
```
  

### 3️⃣ Taxonomia de Reads e Contigs - Kraken2 e MetaPhlAn

- Classificação taxonômica das reads (opcional, pode rodar em paralelo).

- Saída: Perfis taxonômicos das comunidades.

```
# Stub:
nextflow run kraken_e_metaphlan.nf -c your/config/path --outdir /your/taxonomy_output/path -stub -profile stub
# Comando:
nextflow run kraken_e_metaphlan.nf -c your/config/path --outdir /your/taxonomy_output/path -resume -bg
```


### 4️⃣ Taxonomia de Bins - GTDBTk

- Classificação taxonômica dos bins obtidos.

- Saída: gtdbtk.*.summary.tsv - Classificações taxonômicas
  
- Esses arquivos são necessários para os passos de anotação!

```
# Stub:
nextflow run GTDBTk.nf -c your/config/path --outdir /your/gtdbtk_output/path -stub -profile stub
# Comando:
nextflow run GTDBTk.nf -c your/config/path --outdir /your/gtdbtk_output/path -resume -bg
```
  

### 5️⃣ Anotação Funcional - Prokka OU Bakta + EggNOG

- Escolha um dos métodos de anotação:

    - Opção A: Prokka + EggNOG

    - Opção B: Bakta + EggNOG

- Saída: Arquivos de anotação funcional (GFF, GenBank, FASTA de proteínas, anotações funcionais).

- Prokka: 
``` 
# Stub:
nextflow run prokka_e_eggnog_copy.nf --input /your/basalt_result/path --outdir /your/prokka_output_stub/path -stub -profile stub
# Comando:
nextflow run prokka_e_eggnog_copy.nf --input /your/basalt_result/path --outdir /your/prokka_output/path -resume -bg
```
- Bakta
```
# Stub:
nextflow run bakta.nf --input /your/basalt_result/path --outdir /your/bakta_output_stub/path -stub -profile stub
# Comando:
nextflow run bakta.nf --input /your/basalt_result/path --outdir /your/bakta_output/path -resume -bg
```


## 📦 Dependências

Bancos de Dados Necessários:

- Kraken2: Banco de dados padrão ou customizado

- MetaPhlAn: Banco CHOCOPhlAn

- GTDB-Tk: Release 220 ou superior

- EggNOG-mapper: Banco de dados EggNOG

- Bakta: Banco de dados Bakta (light ou full)



## :hammer: Ferramentas

- Nextflow ≥ 24.10

- Conda/Mamba (para ambientes isolados)

- Docker

- Módulos nf-core apropriados



## 📧 Autora

- Inaiá Ramos Aguiar (AGUIAR, I. R)

- inaia.aguiar@alumni.usp.br

