export PATH=$PATH:/usr/local/bin
alias ar='asciinema rec'
alias ap='asciinema play'
alias psx="(ps -eo \"%P %p %c\" |awk 'NR==1' && ps -eo \"%P %p %c\" | grep -v PPID|sort -n) |less"
alias psk="(ps aux | awk 'NR==1' && ps aux |grep -E \\\\[\|\\\\] |grep -vE grep\|sshd) |less"
alias brc=". ~/.bashrc && echo reread .bashrc"
function psg() {
  thing=$1
  ps -eo "ppid pid stat cmd" |awk 'NR==1'
  ps -eo "ppid pid stat cmd" |grep -w $thing |grep -v grep
}
