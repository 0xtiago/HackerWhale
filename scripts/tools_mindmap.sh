#!/bin/bash

# Lê expansion_script.sh
input_file="expansion_script.sh"

# Nome do arquivo de saída
output_file="../assets/tools.dot"
png_file="../assets/tools_map.png"
markdown_file="../assets/tools_list.md"

# Cores personalizadas
color_letters="yellow"                  # Cor das letras (nível intermediário)
color_functions="lightslateblue"        # Cor das funções
color_edges="grey"                      # Cor das arestas
color_background="transparent"          # Cor de fundo transparente

# Detecta o sistema operacional e define o comando grep apropriado
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    grep_command="grep -oP '^\s*\K\w+'"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    grep_command="grep -o '^[[:space:]]*\w\+'"
else
    echo "Sistema operacional não suportado"
    exit 1
fi

# Inicializa o arquivo .dot para o Graphviz
{
    echo "digraph G {"
    echo "    layout=circo;"
    echo "    bgcolor=\"$color_background\";"  # Define o fundo transparente
    echo "    node [shape=box, fontsize=12, style=filled];"
    echo "    graph [overlap=false, splines=true, fontname=Helvetica, fontsize=10];"
    echo "    edge [color=$color_edges, arrowsize=0.5];"
} > $output_file

# Variável para controle interno da função callInstallTools
inside_function=false

# Arrays para armazenar funções agrupadas por letra inicial
letters=()
functions=()

# Lê o arquivo linha por linha e armazena as funções em arrays
while IFS= read -r line; do
    # Remove espaços em branco no início e no fim da linha
    line=$(echo "$line" | xargs)
    
    # Verifica o início da função callInstallTools
    if [[ "$line" == "callInstallTools(){" ]]; then
        inside_function=true
        echo "Encontrado início de callInstallTools"
        continue
    fi

    # Verifica o fim da função callInstallTools
    if [[ $inside_function == true && "$line" == "}" ]]; then
        inside_function=false
        echo "Encontrado fim de callInstallTools"
        continue
    fi

    # Captura funções chamadas dentro de callInstallTools
    if [[ $inside_function == true && ! "$line" =~ ^# && ! -z "$line" ]]; then
        func_name=$(echo "$line" | awk '{print $1}')
        if [[ ! -z "$func_name" ]]; then
            # Remove ou substitui hifens para compatibilidade com o formato DOT
            func_name=$(echo "$func_name" | sed 's/-/_/g')
            first_char=$(echo "$func_name" | cut -c 1 | tr '[:lower:]' '[:upper:]')
            functions+=("$first_char $func_name")
            if [[ ! " ${letters[@]} " =~ " ${first_char} " ]]; then
                letters+=("$first_char")
            fi
        fi
    fi
done < "$input_file"

# Ordena as letras em ordem alfabética
letters=($(printf "%s\n" "${letters[@]}" | sort))

# Escreve a estrutura no arquivo .dot
{
    echo "    Tools -> {"
    for letter in "${letters[@]}"; do
        echo "        $letter [fillcolor=$color_letters];"
    done
    echo "    };"

    for letter in "${letters[@]}"; do
        echo "    $letter -> {"
        for entry in "${functions[@]}"; do
            if [[ "$entry" == "$letter "* ]]; then
                func_name=$(echo "$entry" | awk '{print $2}')
                echo "        $func_name [fillcolor=$color_functions];"
            fi
        done
        echo "    };"
    done
    echo "}"
} >> $output_file

# Verifica o conteúdo do arquivo .dot
echo "Conteúdo do arquivo .dot gerado:"
cat $output_file

# Gera o arquivo .md com a lista de funções no formato de tabela
{
    echo "|  #  | Tool |"
    echo "|-----|---------|"
    count=1
    for letter in "${letters[@]}"; do
        for entry in "${functions[@]}"; do
            if [[ "$entry" == "$letter "* ]]; then
                func_name=$(echo "$entry" | awk '{print $2}')
                echo "|  $count. | $func_name  |"
                ((count++))
            fi
        done
    done
} > $markdown_file

# Verifica o conteúdo do arquivo .md
echo "Conteúdo do arquivo .md gerado:"
cat $markdown_file

# Gera o PNG usando o Graphviz
dot -Kcirco -Tpng $output_file -o $png_file

echo "Mapa mental gerado em $png_file"
