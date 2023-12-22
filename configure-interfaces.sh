#!/bin/bash
function consultarIP() {
	interfaz=$1
	echo ""
	echo "==========================================================================="
	ip address show dev $interfaz | grep inet | head -1 | tr " " ":" | cut -d":" -f6
}

function consultarMAC() {
	interfaz=$1
	echo ""
	echo "==========================================================================="
	cat /sys/class/net/$interfaz/address
}
function configurarIPv4() {
	interfaz=$1
	fichero="/etc/network/interfaces.d/interface-$interfaz.conf"
	echo ""
	echo "==========================================================================="
	read -p "Como quieres configurarlo [static/dhcp]:" modo
	if [[ $modo == "static" ]];
	then
		read -p "Introduce tu dirección de red: " ip_address
		read -p "Introduce tu máscara: " mascara_red
		read -p "Introduce tu gateway: " gateway

		echo "auto $interfaz" > $fichero
		echo "iface $interfaz inet $modo" >> $fichero
		echo "address	$ip_address" >> $fichero
		echo "netmask	$mascara_red" >> $fichero
		if [[ $gateway != "" ]]
		then
			echo "gateway	$gateway" >> $fichero
		fi
		read -p "Quieres añadir un servidor DNS? [S/n]" op_dns
		if [[ $op_dns == "S" || $op_dns == "s" ]]
		then
			read -p "Introduce la dirección IP del servidor DNS primario: " ip_dns
			echo "dns-nameserver	$ip_dns" >> $fichero

			read -p "Introduce la dirección IP del servidor DNS secundario: " ip_dns
			echo "dns-nameserver	$ip_dns" >> $fichero
		fi

	elif [[ $modo == "dhcp" ]];
	then
		echo "auto $interfaz" > $fichero
		echo "iface $interfaz inet $modo" >> $fichero
	fi

	systemctl restart networking.service
}
echo "###########################################################################"
echo "# ESTE SCRIPT REALIZA LA CONFIGURACION DEL RED PARA UN TERMINAL EN DEBIAN #"
echo "###########################################################################"
echo ""
echo "A partir de la siguiente lista, elije la interfaz a configurar:"
echo ""
for linea in $(ls -1 /sys/class/net); do
	if [[ $linea != "lo" ]];
	then
		echo $linea
	fi
done
echo "==========================================================================="

read -p "Escribe la interfaz: " interfaz_red

if [[ $(ls -1 /sys/class/net | grep $interfaz_red | wc -l) -eq 1 ]];
then
	echo "Que deseas hacer:"
	echo "[1] Consultar Dirección IP."
	echo "[2] Consultar Dirección MAC."
	echo "[3] Configurar IPv4"
	read -s opcion
	case $opcion in
		1)
			consultarIP $interfaz_red
			;;
		2)
			consultarMAC $interfaz_red
			;;
		3)
			configurarIPv4 $interfaz_red
			;;
	esac
fi
