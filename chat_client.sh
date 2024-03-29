#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Nie podano parametru"
	exit
fi

licz7=`find -name "$1" | wc -l`
licz8=`find -type d -name "$1" | wc -l`

if [ $licz7 -gt 0 ] && [ $licz8 -eq 0 ]; then
	echo "Istnieje plik o nazwie $1 i nie jest to katalog."
	echo "Skrypt nie może kontynuować działania"
	echo "Możesz podać nazwę nieistniejącego katalogu"
	exit
fi

licz4=`find -type d -name "$1" | wc -l`

if [ $licz4 -gt 1 ]; then
	echo "Jest za dużo katalogów o podanej nazwie"
	exit
elif [ $licz4 -eq 0 ]; then
	mkdir $1
fi

licz5=`find $1 -type d -name "prywatne" | wc -l`

if [ $licz5 -eq 0 ]; then
	mkdir ./$1/prywatne
fi


echo "Podaj swój login"
read login
echo

proba=`find -name "uzytkownicy_na_projekt_$1.txt" | wc -l`

if [ $proba -eq 0 ]; then
	touch uzytkownicy_na_projekt_$1.txt
fi

licz3=`cat uzytkownicy_na_projekt_$1.txt 2>/dev/null | wc -l`

uzytkownicy=(`cat uzytkownicy_na_projekt_$1.txt`)

if [[ " ${uzytkownicy[@]} " =~ " ${login} " ]]; then
	echo "Uzytkownik $login ponownie zalogowany"
fi

if [[ ! " ${uzytkownicy[@]} " =~ " ${login} " ]]; then
	echo "Witaj $login!"
	uzytkownicy[$licz3]=$login
	echo "$login" >> uzytkownicy_na_projekt_$1.txt
fi

echo -n "Zalogowani użytkownicy: "
for item in ${uzytkownicy[@]}; do
	echo -n "$item, "
done
echo

x=1;
up=0;

echo
echo "MOŻLIWE DZIAŁANIA"
echo "1. stworzyć pokój"
echo "2. wejść do pokoju"
echo "3. odświeżyć wiadomości w pokoju"
echo "4. odebrać wiadomości prywatne"
echo "5. wysłać wiadomość do pokoju, w którym jestem"
echo "6. wysłać wiadomość prywatną, o ile użytkownik jest dostępny"
echo "7. włączyć przełącznik -UPPER (wszystkie wiadomości będą pisane wielką literą)"
echo "0. Zakończyć działanie programu"

while [ $x -gt 0 ]; do
	echo
	#mozliwe=(`find $1 -type f -name "*.txt" | cut -d "/" -f 2 | cut -d "." -f 1`)
	#echo "Dostępne pokoje: ${mozliwe[*]}"
	#echo
	echo "Jakie działanie chcesz wykonać?"
	read x

	if [ $x -eq 0 ] 2>/dev/null; then
		echo "Koniec programu."
		exit

	elif [ $x -eq 1 ] 2>/dev/null; then
		echo
		echo "Podaj nazwę nowego pokoju"
		read pokoj

		licz=`find $1 -name "$pokoj.txt" | wc -l`

		if [ $licz -gt 0 ]; then
			echo "Już istnieje taki pokój"
		else
			touch ./$1/$pokoj.txt
		fi

	elif [ $x -eq 2 ] 2>/dev/null; then
		echo
		mozliwe=(`find $1 -type f -name "*.txt" | cut -d "/" -f 2 | cut -d "." -f 1`)

		if [ ${#mozliwe[@]} -eq 0 ]; then
			echo "Nie ma żadnego dostępnego pokoju."
			echo "Stwórz nowy pokój"
		else
			echo "Dostępne pokoje: ${mozliwe[*]}"
			echo
			echo "Podaj nazwę pokoju, do którego chcesz wejść"
			read wejsc
			echo

			licz2=`find $1 -name "$wejsc.txt" | wc -l`

			if [ $licz2 -eq 1 ]; then
				echo "Jesteś w pokoju $wejsc"
			else
				echo "Wejście do tego pokoju jest niemożliwe"
			fi
		fi

	elif [ $x -eq 3 ] 2>/dev/null; then
		if [ -z "$wejsc" ]; then
			echo "Nie wszedłeś do żadnego pokoju"
		else
			echo
			echo "Wiadomości w pokoju $wejsc: "
			cat ./$1/$wejsc.txt
			echo
		fi

	elif [ $x -eq 4 ] 2>/dev/null; then
		licz6=`find ./$1/prywatne/ -name "$login" | wc -l`

		if [ $licz6 -eq 0 ]; then
			echo "Nie masz żadnych prywatnych wiadomości"
		else
			echo "Twoje prywatne wiadomości:"
			cat ./$1/prywatne/$login
		fi

	elif [ $x -eq 5 ] 2>/dev/null; then
		if [ -z "$wejsc" ]; then
			echo "Nie wszedłeś do żadnego pokoju"
		else

			if [ $up -eq 0 ]; then
				echo "Podaj swoją wiadomość, którą wyślesz do pokoju $wejsc"
				read wiadomosc

				echo "(`date +%R` `date +%F`) $login: $wiadomosc" >> ./$1/$wejsc.txt

			elif [ $up -eq 1 ];then 
				echo "Podaj swoją wiadomość, którą wyślesz do pokoju $wejsc"
				read wiadomosc

				echo "(`date +%R` `date +%F`) $login: `echo $wiadomosc | tr [:lower:] [:upper:]`" >> ./$1/$wejsc.txt
			fi
		fi

	elif [ $x -eq 6 ] 2>/dev/null; then
		echo "Podaj login użytkownika, do którego chcesz wysłać prywatną wiadomość: "
		read pryw

		if [[ ! " ${uzytkownicy[@]} " =~ " ${pryw} " ]]; then
			echo "Niestety ten użytkownik nie jest dostępny. "
		else
			if [ $up -eq 0 ]; then
				echo "Podaj treść wiadomości: "
				read wiadomosc2

				echo "(`date +%R` `date +%F`) $login: $wiadomosc2" >> ./$1/prywatne/$pryw
			elif [ $up -eq 1 ];then
				echo "Podaj treść wiadomości: "
				read wiadomosc2

				#echo "(`date +%R` `date +%F`) $login: `echo $wiadomosc2 | tr [:lower:] [:upper:]`"
				echo "(`date +%R` `date +%F`) $login: `echo $wiadomosc2 | tr [:lower:] [:upper:]`" >> ./$1/prywatne/$pryw
			fi
		fi

	elif [ $x -eq 7 ] 2>/dev/null; then
		if [ $up -eq 0 ]; then
			up=1;
			echo "Przełącznik -UPPER włączony"
		else
			up=0;
			echo "Przełącznik -UPPER wyłączony"
		fi

	else
		echo "Nieznane polecenie"
		x=8
	fi

done
