dotfiles=$HOME/dotfiles
quote_file=$dotfiles/quotes.text
quote=$(shuf -n 1 $quote_file | iconv -f utf8 -t ascii//TRANSLIT)

echo "$quote" | pokemonsay
