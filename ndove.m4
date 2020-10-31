#!/bin/bash
#
# ARG_POSITIONAL_SINGLE([ssh-destination], [ssh destination you wan to connect to],)
# ARG_POSITIONAL_SINGLE([private-port], [to local port you want to forward],)
# ARG_POSITIONAL_SINGLE([public-port], [the port on the remote server],)
# ARG_POSITIONAL_SINGLE([public-ip4], [ipv4 address of the public server],)
# ARG_POSITIONAL_SINGLE([public-ip6], [ipv6 address of the public server], ["::1"])
# ARG_HELP([This script allows you to expose a local port through ssh])
# ARGBASH_GO

# [ <-- needed because of Argbash

SSH_DESTINATION=$_arg_ssh_destination
PRIVATE_PORT=$_arg_private_port
TUNNEL_PORT=60123

global_variables=$(cat <<ENDVAR

PUBLIC_IP4=$_arg_public_ip4
PUBLIC_IP6=$_arg_public_ip6
PUBLIC_PORT=$_arg_public_port
TUNNEL_PORT=$TUNNEL_PORT
ENDVAR
)

ssh_command=$(cat <<'ENDSSH'

function socat_tunnel {
    ip_version=$1
    bind_address=$2
    echo "Binding $PUBLIC_PORT to $ip_version:$bind_address"
    socat tcp-listen:$PUBLIC_PORT,pf=$ip_version,reuseaddr,fork,bind=$bind_address tcp:localhost:$TUNNEL_PORT
}

function print_success {
    echo "Sucessfully forwarded local port"
}

if ! command -v socat &> /dev/null
then
    echo "socat is not installed on remote ssh server"
    exit
fi


(trap "kill 0" SIGINT; socat_tunnel ip4 $PUBLIC_IP4 & socat_tunnel ip6 $PUBLIC_IP6 & print_success & cat)

ENDSSH
)

# For debugging:
#echo "$global_variables$ssh_command"

ssh -t -R $TUNNEL_PORT:localhost:$PRIVATE_PORT $SSH_DESTINATION "bash -c '$global_variables$ssh_command'"

# ] <-- needed because of Argbash