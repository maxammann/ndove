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

PUBLIC_IP4=$_arg_public_ip4
PUBLIC_IP6=$_arg_public_ip6
SSH_DESTINATION=$_arg_ssh_destination
PRIVATE_PORT=$_arg_private_port
PUBLIC_PORT=$_arg_public_port

TUNNEL_PORT=60123

ssh -tt -R $TUNNEL_PORT:localhost:$PRIVATE_PORT $SSH_DESTINATION << EOF
function socat_tunnel {
    ip_version=\$1
    bind_address=\$2
    echo "Running \$ip_version tunnel"
    socat tcp-listen:$PUBLIC_PORT,pf=\$ip_version,reuseaddr,fork,bind=\$bind_address tcp:localhost:$TUNNEL_PORT
}

if ! command -v socat &> /dev/null
then
    echo "socat is not installed on remote ssh server"
    exit
fi


(trap 'kill 0' SIGINT; socat_tunnel ip4 $PUBLIC_IP4 & socat_tunnel ip6 $PUBLIC_IP6)
EOF

# ] <-- needed because of Argbash