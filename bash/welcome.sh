dotfiles=$HOME/dotfiles
pokemon_path=$dotfiles/pokemonsay/cows
quote_file=$dotfiles/quotes.text
quote=$(shuf -n 1 $quote_file | iconv -f utf8 -t ascii//TRANSLIT)

pokemon_cow=$(find $pokemon_path -name "*.cow" | shuf -n1)
filename=$(basename "$pokemon_cow")
pokemon_name="${filename%.*}"

echo -e $quote | cowsay -f "$pokemon_cow"
echo $pokemon_name
# pokemonsay -- $quote