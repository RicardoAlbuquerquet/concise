#!/usr/bin/env bash
# Exercises the hook scripts outside a session, with a fake $HOME and a
# fake `claude` on PATH — no API calls, no writes outside the temp dir.
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
G="$REPO/skills/concise/hooks/credit-guard.sh"
N="$REPO/skills/concise/hooks/notices.sh"
U="$REPO/skills/concise/hooks/self-update.sh"
I="$REPO/skills/concise/hooks/inject-core.sh"
FH="${TMPDIR:-/tmp}/concise-hooktest.$$"; rm -rf "$FH"; mkdir -p "$FH/.claude"
trap 'rm -rf "$FH"' EXIT
pass=0; fail=0
t () { # nome, esperado(deny|allow), stdin
  out=$(printf '%s' "$3" | HOME="$FH" bash "$G" "MOTIVO" .concise-no-credit-guard)
  got=allow; case "$out" in *permissionDecision*) got=deny;; esac
  if [ "$got" = "$2" ]; then pass=$((pass+1)); printf 'ok    %-46s %s\n' "$1" "$got"
  else fail=$((fail+1)); printf 'FALHA %-46s esperado=%s obtido=%s\n' "$1" "$2" "$got"; fi
}
# a string de credito e montada em runtime para nao aparecer literal aqui
CRED="Co-Authored-By: Cla""ude <noreply@anthropic.com>"
GEN="Genera""ted with [Cla""ude Code](https://claude.com)"

t "commit simples com trailer"           deny  "{\"command\":\"git commit -m 'fix\n\n$CRED'\"}"
t "corrente composta com trailer"        deny  "{\"command\":\"git add -A && git commit -m 'x\n$CRED' && git push\"}"
t "git -C outro-dir commit"              deny  "{\"command\":\"git -C /tmp/repo commit -m 'x\n$CRED'\"}"
t "gh pr create com generated with"      deny  "{\"command\":\"gh pr create --body 'ok\n$GEN'\"}"
t "gh pr edit"                           deny  "{\"command\":\"gh pr edit 3 --body '$GEN'\"}"
t "gh issue comment"                     deny  "{\"command\":\"gh issue comment 1 --body '$CRED'\"}"
t "gh release create --notes"            deny  "{\"command\":\"gh release create v1 --notes '$GEN'\"}"
t "commit limpo"                         allow "{\"command\":\"git commit -m 'fix the filter'\"}"
t "grep mencionando a string"            allow "{\"command\":\"grep -r '$CRED' docs/\"}"
t "cat de arquivo qualquer"              allow "{\"command\":\"cat notes.md\"}"

# mensagem vinda de arquivo (-F): o furo que a auditoria apontou
printf 'fix\n\n%s\n' "$CRED" > "$FH/msg.txt"
t "git commit -F arquivo com credito"    deny  "{\"command\":\"git commit -F $FH/msg.txt\"}"
printf 'fix limpo\n' > "$FH/ok.txt"
t "git commit -F arquivo limpo"          allow "{\"command\":\"git commit -F $FH/ok.txt\"}"

# o caminho entre aspas e a mensagem lida de volta com cat passavam sem leitura
t "-F com caminho entre aspas duplas"    deny  "{\"command\":\"git commit -F \\\"$FH/msg.txt\\\"\"}"
t "--body-file entre aspas simples"      deny  "{\"command\":\"gh pr create --title x --body-file '$FH/msg.txt'\"}"
t "-m com \$(cat arquivo)"               deny  "{\"command\":\"git commit -m \\\"\$(cat $FH/msg.txt)\\\"\"}"
t "PowerShell Get-Content -Raw"          deny  "{\"command\":\"git commit -m (Get-Content -Raw $FH/msg.txt)\"}"
t "o segundo arquivo da chamada"         deny  "{\"command\":\"gh pr create --body-file $FH/ok.txt && git commit -F $FH/msg.txt\"}"
t "arquivo limpo entre aspas"            allow "{\"command\":\"git commit -F \\\"$FH/ok.txt\\\"\"}"
# o squash grava a mensagem no historico da main
t "gh pr merge --body"                   deny  "{\"command\":\"gh pr merge 3 --squash --body '$CRED'\"}"

# opt-out e escape hatch
touch "$FH/.claude/.concise-no-credit-guard"
t "opt-out por flag"                     allow "{\"command\":\"git commit -m '$CRED'\"}"
rm "$FH/.claude/.concise-no-credit-guard"
out=$(printf '%s' "{\"command\":\"git commit -m '$CRED'\"}" | HOME="$FH" CONCISE_ALLOW_CREDIT=1 bash "$G" "M" .concise-no-credit-guard)
if [ -z "$out" ]; then pass=$((pass+1)); echo "ok    escape hatch CONCISE_ALLOW_CREDIT"; else fail=$((fail+1)); echo "FALHA escape hatch"; fi

echo "--- notices"
out=$(HOME="$FH" bash "$N" concise "BEM-VINDO" "falhou, rode %s")
case "$out" in *systemMessage*BEM-VINDO*) pass=$((pass+1)); echo "ok    boas-vindas emite systemMessage";; *) fail=$((fail+1)); echo "FALHA boas-vindas: $out";; esac
out=$(HOME="$FH" bash "$N" concise "BEM-VINDO" "falhou, rode %s")
[ -z "$out" ] && { pass=$((pass+1)); echo "ok    segunda sessao silencia"; } || { fail=$((fail+1)); echo "FALHA segunda sessao: $out"; }
printf 'concise updated from 1.12.0 to 1.13.0' > "$FH/.claude/.concise-update-note"
out=$(HOME="$FH" bash "$N" concise "BV" "falhou %s")
case "$out" in *"1.13.0"*) pass=$((pass+1)); echo "ok    anuncia versao aplicada";; *) fail=$((fail+1)); echo "FALHA anuncio: $out";; esac
[ -f "$FH/.claude/.concise-update-note" ] && { fail=$((fail+1)); echo "FALHA nota nao foi limpa"; } || { pass=$((pass+1)); echo "ok    nota limpa apos exibir"; }

echo "--- inject-core"
# O output style forcado ja leva o nucleo no system prompt; imprimir de novo no
# inicio da sessao pagava o mesmo texto duas vezes. So com CONCISE_INJECT_CORE=1.
out=$(HOME="$FH" CLAUDE_PLUGIN_ROOT="$REPO/skills/concise" bash "$I" concise-core-override.md core.md)
[ -z "$out" ] && { pass=$((pass+1)); echo "ok    nucleo embarcado nao sai duas vezes"; } || { fail=$((fail+1)); echo "FALHA nucleo duplicado: $(printf '%s' "$out" | head -1)"; }
out=$(HOME="$FH" CONCISE_INJECT_CORE=1 CLAUDE_PLUGIN_ROOT="$REPO/skills/concise" bash "$I" concise-core-override.md core.md | head -1)
case "$out" in "Response style"*) pass=$((pass+1)); echo "ok    CONCISE_INJECT_CORE=1 devolve o nucleo";; *) fail=$((fail+1)); echo "FALHA CONCISE_INJECT_CORE: $out";; esac
printf 'NUCLEO CUSTOM\n' > "$FH/.claude/concise-core-override.md"
out=$(HOME="$FH" CLAUDE_PLUGIN_ROOT="$REPO/skills/concise" bash "$I" concise-core-override.md core.md)
[ "$out" = "NUCLEO CUSTOM" ] && { pass=$((pass+1)); echo "ok    override vence"; } || { fail=$((fail+1)); echo "FALHA override: $out"; }

# a linha de plataforma: o rotulo do bloco tem que ser o shell de quem cola
IC () { HOME="$FH" CONCISE_OS="$1" CLAUDE_PLUGIN_ROOT="$REPO/skills/concise" bash "$I" concise-core-override.md core.md "FENCE powershell" "FENCE macos" "FENCE linux"; }
ic () { # nome, CONCISE_OS, trecho esperado na ultima linha
  out=$(IC "$2" | tail -1)
  case "$out" in *"$3"*) pass=$((pass+1)); echo "ok    $1";;
                 *) fail=$((fail+1)); echo "FALHA $1: $out";; esac
}
ic "windows pede powershell"       windows powershell
ic "macos pede bash"               macos   macos
ic "linux pede bash"               linux   linux
ic "os desconhecido cai em linux"  freebsd linux

# a linha vem depois do override, porque e fato da maquina e nao estilo
out=$(IC windows)
case "$out" in "NUCLEO CUSTOM"*powershell*) pass=$((pass+1)); echo "ok    plataforma sobrevive ao override";;
               *) fail=$((fail+1)); echo "FALHA override+plataforma: $out";; esac

# hooks.json antigo, sem os tres argumentos: nao imprime linha e nao falha
out=$(HOME="$FH" CONCISE_OS=windows CLAUDE_PLUGIN_ROOT="$REPO/skills/concise" bash "$I" concise-core-override.md core.md; echo "rc=$?")
case "$out" in "NUCLEO CUSTOM"*"rc=0") pass=$((pass+1)); echo "ok    sem argumentos nao quebra";;
               *) fail=$((fail+1)); echo "FALHA sem argumentos: $out";; esac

# sem override, a sessao recebe so a linha da plataforma, sem linha em branco antes
rm -f "$FH/.claude/concise-core-override.md"
out=$(IC macos)
[ "$out" = "FENCE macos" ] && { pass=$((pass+1)); echo "ok    sem override sai so a linha da plataforma"; } || { fail=$((fail+1)); echo "FALHA so a plataforma: $out"; }

echo "--- self-update (claude fake)"
mkdir -p "$FH/bin"
printf '#!/usr/bin/env bash\necho chamada >> "%s/calls.log"\n[ "$1" = "plugin" ] && [ "$2" = "update" ] && echo "Plugin updated from 1.12.0 to 1.13.0 for scope user."\nexit 0\n' "$FH" > "$FH/bin/claude"
chmod +x "$FH/bin/claude"; rm -f "$FH/calls.log"
(cd "$FH" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
n1=$(wc -l < "$FH/calls.log" 2>/dev/null | tr -d ' ')
(cd "$FH" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
n2=$(wc -l < "$FH/calls.log" | tr -d ' ')
[ "$n1" = "2" ] && [ "$n2" = "2" ] && { pass=$((pass+1)); echo "ok    throttle da janela (2 chamadas, 2a sessao zero)"; } || { fail=$((fail+1)); echo "FALHA throttle: n1=$n1 n2=$n2"; }
# dentro do repo do proprio marketplace o carimbo do dia nao segura
(cd "$REPO" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
n3=$(wc -l < "$FH/calls.log" | tr -d ' ')
[ "$n3" = "4" ] && { pass=$((pass+1)); echo "ok    no repo do marketplace ignora o carimbo"; } || { fail=$((fail+1)); echo "FALHA bypass no repo: n3=$n3"; }
# e tambem num subdiretorio do repo — a raiz e resolvida via git
(cd "$REPO/skills/concise" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
n3b=$(wc -l < "$FH/calls.log" | tr -d ' ')
[ "$n3b" = "6" ] && { pass=$((pass+1)); echo "ok    subdiretorio do repo tambem ignora o carimbo"; } || { fail=$((fail+1)); echo "FALHA bypass em subdir: n3b=$n3b"; }
# e um repo qualquer continua respeitando o carimbo
mkdir -p "$FH/outro"
(cd "$FH/outro" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
n4=$(wc -l < "$FH/calls.log" | tr -d ' ')
[ "$n4" = "6" ] && { pass=$((pass+1)); echo "ok    fora do repo o carimbo continua valendo"; } || { fail=$((fail+1)); echo "FALHA carimbo fora do repo: n4=$n4"; }
grep -q "1.13.0" "$FH/.claude/.concise-update-note" 2>/dev/null && { pass=$((pass+1)); echo "ok    grava nota de versao"; } || { fail=$((fail+1)); echo "FALHA nota de versao"; }
[ -d "$FH/.claude/.concise-update-lock" ] && { fail=$((fail+1)); echo "FALHA lock ficou para tras"; } || { pass=$((pass+1)); echo "ok    lock liberado"; }
# janela configuravel: com 0 hora, a sessao seguinte checa de novo
rm -f "$FH/calls.log"; printf '0' > "$FH/.claude/.concise-update-hours"
(cd "$FH/outro" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
n5=$(wc -l < "$FH/calls.log" | tr -d ' ')
[ "$n5" = "2" ] && { pass=$((pass+1)); echo "ok    janela em horas e configuravel"; } || { fail=$((fail+1)); echo "FALHA janela configuravel: n5=$n5"; }
rm -f "$FH/.claude/.concise-update-hours"

# falha nao carimba: a sessao seguinte tenta de novo, sem esperar a janela
rm -f "$FH/.claude/.concise-update-stamp" "$FH/calls.log"
printf '#!/usr/bin/env bash\necho chamada >> "%s/calls.log"\nexit 1\n' "$FH" > "$FH/bin/claude"; chmod +x "$FH/bin/claude"
(cd "$FH/outro" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
(cd "$FH/outro" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
n6=$(wc -l < "$FH/calls.log" | tr -d ' ')
[ -s "$FH/.claude/.concise-update-stamp" ] && { fail=$((fail+1)); echo "FALHA falha carimbou e segurou a janela"; } || { pass=$((pass+1)); echo "ok    falha deixa o carimbo como estava"; }
[ "$n6" = "2" ] && { pass=$((pass+1)); echo "ok    falha tenta de novo na sessao seguinte"; } || { fail=$((fail+1)); echo "FALHA retry apos falha: n6=$n6"; }
[ -s "$FH/.claude/.concise-update-failed" ] && { pass=$((pass+1)); echo "ok    marca falha para aviso semanal"; } || { fail=$((fail+1)); echo "FALHA marcador de falha"; }
# opt-out do self-update
rm -f "$FH/.claude/.concise-update-stamp" "$FH/calls.log"; touch "$FH/.claude/.concise-no-self-update"
HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise
[ ! -s "$FH/calls.log" ] && { pass=$((pass+1)); echo "ok    opt-out do self-update"; } || { fail=$((fail+1)); echo "FALHA opt-out self-update"; }
rm -f "$FH/.claude/.concise-no-self-update"

# Uma sessao que termina antes da checagem mata o hook sem rodar o trap: a
# trava fica e nada mais e gravado. Um `claude -p` que dura um segundo fez isso
# em todo merge, e a trava de uma hora segurava as checagens seguintes.
mata () { printf '#!/usr/bin/env bash\necho chamada >> "%s/calls.log"\nkill -9 $PPID\n' "$FH" > "$FH/bin/claude"; chmod +x "$FH/bin/claude"; }
atualiza () { printf '#!/usr/bin/env bash\necho chamada >> "%s/calls.log"\n[ "$1" = "plugin" ] && [ "$2" = "update" ] && echo "concise is already at the latest version (1.84.0)."\nexit 0\n' "$FH" > "$FH/bin/claude"; chmod +x "$FH/bin/claude"; }
rm -f "$FH/.claude/.concise-update-stamp" "$FH/.claude/.concise-update-failed" "$FH/calls.log"
mata
( cd "$FH/outro" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise; true ) 2>/dev/null
[ -f "$FH/.claude/.concise-update-failed" ] && { pass=$((pass+1)); echo "ok    checagem morta no meio conta como falha"; } || { fail=$((fail+1)); echo "FALHA checagem morta no meio nao marcou falha"; }
[ -d "$FH/.claude/.concise-update-lock" ] && { pass=$((pass+1)); echo "ok    checagem morta deixa a trava, como na sessao real"; } || { fail=$((fail+1)); echo "FALHA o teste nao reproduziu a trava deixada"; }
atualiza
(cd "$FH/outro" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
[ -f "$FH/.claude/.concise-update-stamp" ] && { fail=$((fail+1)); echo "FALHA trava recente foi ignorada"; } || { pass=$((pass+1)); echo "ok    trava de agora ainda segura a checagem"; }
perl -e '$t = time - 180; utime $t, $t, $ARGV[0]' "$FH/.claude/.concise-update-lock"
(cd "$FH/outro" && HOME="$FH" PATH="$FH/bin:$PATH" bash "$U" concise)
[ -s "$FH/.claude/.concise-update-stamp" ] && { pass=$((pass+1)); echo "ok    trava de tres minutos nao segura mais a checagem"; } || { fail=$((fail+1)); echo "FALHA trava de tres minutos ainda segura a checagem"; }
[ -f "$FH/.claude/.concise-update-failed" ] && { fail=$((fail+1)); echo "FALHA sucesso nao limpou a marca de falha"; } || { pass=$((pass+1)); echo "ok    sucesso limpa a marca de falha"; }

echo "--- guarda de credito em arquivo e quadro"
CG="$REPO/skills/concise/hooks/credit-guard.sh"
cg () { printf '%s' "$1" | HOME="$FH" bash "$CG" "RAZAO" .concise-no-credit-guard; }

# assinatura no fim de um arquivo: bloqueia
payload=$(node -e 'process.stdout.write(JSON.stringify({tool_name:"Write",tool_input:{file_path:"a.md",content:"fix: x\n\nCo-Authored-By: Claude Opus 5 <noreply@anthropic.com>\n"}}))')
case "$(cg "$payload")" in *deny*) pass=$((pass+1)); echo "ok    credito em arquivo e barrado";; *) fail=$((fail+1)); echo "FALHA credito em arquivo passou";; esac

# a regra citada em prosa continua passando: este repo documenta o formato
payload=$(node -e 'process.stdout.write(JSON.stringify({tool_name:"Write",tool_input:{file_path:"CONTRIBUTING.md",content:"A regra proibe co-authored-by de modelo na mensagem."}}))')
[ -z "$(cg "$payload")" ] && { pass=$((pass+1)); echo "ok    texto sobre a regra passa"; } || { fail=$((fail+1)); echo "FALHA texto sobre a regra foi barrado"; }

# o mesmo credito indo para um card do quadro: bloqueia
payload=$(node -e 'process.stdout.write(JSON.stringify({tool_name:"mcp__vx-work__vx_create_activity",tool_input:{title:"x",description:"feito\n\n\ud83e\udd16 Generated with [Claude Code](https://claude.com/claude-code)"}}))')
case "$(cg "$payload")" in *deny*) pass=$((pass+1)); echo "ok    credito em card do quadro e barrado";; *) fail=$((fail+1)); echo "FALHA credito em card passou";; esac

# e o hooks.json registra o guarda nas ferramentas de escrita e do quadro
for port in concise; do
  m=$(perl -MJSON::PP -e 'local $/; my $j = decode_json(<STDIN>); print join ",", map { $_->{matcher} } grep { grep { $_->{command} =~ /credit-guard/ } @{$_->{hooks}} } @{$j->{hooks}{PreToolUse}}' < "$REPO/skills/$port/hooks/hooks.json")
  case "$m" in *Write*) case "$m" in *mcp__*) pass=$((pass+1)); echo "ok    guarda de $port cobre escrita e quadro";; *) fail=$((fail+1)); echo "FALHA guarda de $port sem o quadro: $m";; esac;; *) fail=$((fail+1)); echo "FALHA guarda de $port sem escrita: $m";; esac
done

echo "--- lacunas do guarda e do self-update"
CG="$REPO/skills/concise/hooks/credit-guard.sh"
for caso in "git -c k=v commit" "git tag anotada" "glab mr create"; do
  case "$caso" in
    "git -c k=v commit") payload=$(node -e 'process.stdout.write(JSON.stringify({tool_name:"Bash",tool_input:{command:process.argv[1]}}))' "git -c core.safecrlf=false commit -m \"fix: x\\n\\nCo-Authored-By: Claude Opus 5 <noreply@anthropic.com>\"") ;;
    "git tag anotada")   payload=$(node -e 'process.stdout.write(JSON.stringify({tool_name:"Bash",tool_input:{command:process.argv[1]}}))' "git tag -a v1 -m \"release\\n\\nCo-Authored-By: Claude Opus 5 <noreply@anthropic.com>\"") ;;
    "glab mr create")    payload=$(node -e 'process.stdout.write(JSON.stringify({tool_name:"Bash",tool_input:{command:process.argv[1]}}))' "glab mr create --title x --description \"feito\\n\\nCo-Authored-By: Claude Opus 5 <noreply@anthropic.com>\"") ;;
  esac
  out=$(printf '%s' "$payload" | HOME="$FH" bash "$CG" RAZAO .concise-no-credit-guard)
  case "$out" in *deny*) pass=$((pass+1)); echo "ok    guarda barra credito em $caso";; *) fail=$((fail+1)); echo "FALHA guarda deixou passar $caso";; esac
done

# sem o CLI no PATH nada atualiza: a marca de falha e o que chega ao aviso semanal
SU="$FH/sem-cli"; mkdir -p "$SU/.claude" "$SU/bin"
for b in date find git mkdir rmdir cat grep sed head printf; do p=$(command -v "$b") && ln -sf "$p" "$SU/bin/$b" 2>/dev/null || cp "$p" "$SU/bin/" 2>/dev/null; done
(cd "$SU" && HOME="$SU" PATH="$SU/bin" "$BASH" "$REPO/skills/concise/hooks/self-update.sh" concise)
[ -f "$SU/.claude/.concise-update-failed" ] && { pass=$((pass+1)); echo "ok    self-update sem CLI deixa a marca de falha"; } || { fail=$((fail+1)); echo "FALHA self-update sem CLI saiu calado"; }

echo "--- guarda le o arquivo nomeado por variavel"
CG="$REPO/skills/concise/hooks/credit-guard.sh"
VD="$FH/vars"; mkdir -p "$VD"
T="Co-Authored"; T="$T-By: Claude Opus 5 <noreply@anthropic.com>"
printf 'fix: x\n\n%s\n' "$T" > "$VD/msg.txt"; cp "$VD/msg.txt" "$FH/msg.txt"
printf 'fix: x\n' > "$VD/limpo.txt"
cgv () { payload=$(node -e 'process.stdout.write(JSON.stringify({tool_name:process.argv[1],tool_input:{command:process.argv[2]}}))' "$1" "$2"); printf '%s' "$payload" | HOME="$FH" bash "$CG" RAZAO .concise-no-credit-guard; }
while IFS='|' read -r nome ferramenta comando; do
  case "$(cgv "$ferramenta" "$comando")" in *deny*) pass=$((pass+1)); echo "ok    guarda le arquivo por $nome";; *) fail=$((fail+1)); echo "FALHA guarda nao leu arquivo por $nome";; esac
done <<LISTA
variavel do bash|Bash|W="$VD"; gh pr create --title x --body-file "\$W/msg.txt"
export|Bash|export W=$VD && git commit -F "\$W/msg.txt"
til|Bash|git commit -F ~/msg.txt
variavel HOME|Bash|git commit -F "\$HOME/msg.txt"
variavel do PowerShell|PowerShell|\$W = "$VD"; gh pr create --title x --body-file "\$W/msg.txt"
env do PowerShell|PowerShell|git commit -F "\$env:HOME/msg.txt"
LISTA
# a mesma resolucao nao inventa credito numa mensagem limpa
case "$(cgv Bash "W=\"$VD\"; git commit -F \"\$W/limpo.txt\"")" in *deny*) fail=$((fail+1)); echo "FALHA guarda barrou mensagem limpa por variavel";; *) pass=$((pass+1)); echo "ok    mensagem limpa por variavel passa";; esac

echo "--- codex: o mesmo plugin, sem estilo de saida"
HK="$REPO/skills/concise/hooks"
CX="$FH/codex"; mkdir -p "$CX/.claude"
cx () { HOME="$CX" PLUGIN_ROOT="$REPO/skills/concise" CLAUDE_PLUGIN_ROOT="$REPO/skills/concise" "$@"; }

# sem estilo de saida forcado, o nucleo entra inteiro como additionalContext
out=$(cx bash "$HK/inject-core.sh" concise-core-override.md core.md WIN MAC LINUX)
printf '%s' "$out" | perl -MJSON::PP -e 'local $/; my $j = decode_json(<STDIN>); my $c = $j->{hookSpecificOutput}{additionalContext}; exit(($j->{hookSpecificOutput}{hookEventName} eq "SessionStart" && $c =~ /first sentence/ && $c =~ /(WIN|MAC|LINUX)$/) ? 0 : 1)' &&
  { pass=$((pass+1)); echo "ok    codex recebe o nucleo e a linha do shell no inicio"; } || { fail=$((fail+1)); echo "FALHA codex sem nucleo no inicio: ${out:0:120}"; }

# o override do usuario vence o nucleo embarcado tambem no codex
printf 'NUCLEO DO USUARIO\n' > "$CX/.claude/concise-core-override.md"
out=$(cx bash "$HK/inject-core.sh" concise-core-override.md core.md WIN MAC LINUX)
case "$out" in *"NUCLEO DO USUARIO"*) case "$out" in *"first sentence"*) fail=$((fail+1)); echo "FALHA codex juntou override e nucleo";; *) pass=$((pass+1)); echo "ok    codex usa o override do usuario";; esac;; *) fail=$((fail+1)); echo "FALHA codex ignorou o override";; esac
rm -f "$CX/.claude/concise-core-override.md"

# no Claude Code nada muda: sem override, so a linha do shell
out=$(HOME="$CX" CLAUDE_PLUGIN_ROOT="$REPO/skills/concise" CONCISE_OS=macos bash "$HK/inject-core.sh" concise-core-override.md core.md WIN MAC LINUX)
[ "$out" = "MAC" ] && { pass=$((pass+1)); echo "ok    claude segue recebendo so a linha do shell"; } || { fail=$((fail+1)); echo "FALHA claude mudou no inicio: $out"; }

# self-update, aviso de /concise:pr e notas falam de Claude Code: no codex, silencio
mkdir -p "$CX/bin"; printf '#!/usr/bin/env bash\necho chamada >> "%s/calls.log"\n' "$CX" > "$CX/bin/claude"; chmod +x "$CX/bin/claude"
(cd "$CX" && cx env PATH="$CX/bin:$PATH" bash "$HK/self-update.sh" concise)
[ ! -f "$CX/calls.log" ] && [ ! -f "$CX/.claude/.concise-update-failed" ] && { pass=$((pass+1)); echo "ok    codex nao roda o self-update do claude"; } || { fail=$((fail+1)); echo "FALHA self-update rodou no codex"; }
out=$(printf '{"tool_name":"Bash","session_id":"cx","tool_input":{"command":"gh pr create --title x --body y"}}' | cx bash "$HK/route-hint.sh" "RAZAO" .concise-no-route-hint)
[ -z "$out" ] && { pass=$((pass+1)); echo "ok    codex nao manda para /concise:pr"; } || { fail=$((fail+1)); echo "FALHA route-hint negou no codex: $out"; }
out=$(cx bash "$HK/notices.sh" concise "BEM-VINDO" "AVISO %s")
[ -z "$out" ] && { pass=$((pass+1)); echo "ok    codex nao mostra as notas do claude"; } || { fail=$((fail+1)); echo "FALHA notices falou no codex: $out"; }

# o codex edita arquivo por patch, e a linha adicionada chega com "+"
T="Co-Authored"; T="$T-By: Claude Opus 5 <noreply@anthropic.com>"
patch=$(printf '*** Begin Patch\n*** Update File: msg.txt\n@@\n fix: x\n+\n+%s\n*** End Patch' "$T")
payload=$(node -e 'process.stdout.write(JSON.stringify({tool_name:"apply_patch",tool_input:{command:process.argv[1]}}))' "$patch")
out=$(printf '%s' "$payload" | cx bash "$HK/credit-guard.sh" RAZAO .concise-no-credit-guard)
case "$out" in *deny*) pass=$((pass+1)); echo "ok    codex: credito num patch e barrado";; *) fail=$((fail+1)); echo "FALHA codex: credito num patch passou";; esac

# o manifesto do codex acompanha o do claude em nome e versao
cm="$REPO/skills/concise/.codex-plugin/plugin.json"; lm="$REPO/skills/concise/.claude-plugin/plugin.json"
nv () { perl -MJSON::PP -e 'local $/; my $j = decode_json(<STDIN>); print "$j->{name} $j->{version}"' < "$1"; }
[ -f "$cm" ] && [ "$(nv "$cm")" = "$(nv "$lm")" ] && { pass=$((pass+1)); echo "ok    manifesto do codex com o mesmo nome e versao"; } || { fail=$((fail+1)); echo "FALHA manifesto do codex: $(nv "$cm" 2>/dev/null) contra $(nv "$lm")"; }

echo "--- trava no push: le a mensagem que o git guardou"
CG="$REPO/skills/concise/hooks/credit-guard.sh"
PG="$FH/push"; rm -rf "$PG"; mkdir -p "$PG"
git init -q --bare "$PG/remoto.git"
git init -q "$PG/repo" && cd "$PG/repo" && git config user.email t@t && git config user.name t && git checkout -q -b main
echo a > a && git add a && git commit -q -m "base" && git remote add origin "$PG/remoto.git" && git push -q -u origin main 2>/dev/null
T="Co-Authored"; T="$T-By: Claude Opus 5 <noreply@anthropic.com>"
pg () { payload=$(node -e 'process.stdout.write(JSON.stringify({tool_name:"Bash",tool_input:{command:process.argv[1]}}))' "$1"); (cd "${2:-$PG/repo}" && printf '%s' "$payload" | HOME="$FH" bash "$CG" RAZAO .concise-no-credit-guard); }

# commit feito por um jeito que o guarda nao le no comando: arquivo de mensagem apagado depois
printf 'fix: b\n\n%s\n' "$T" > "$PG/msg" && echo b > b && git add b && GIT_EDITOR=true git commit -q -F "$PG/msg" && rm "$PG/msg"
case "$(pg "git push")" in *deny*"Commit "*) pass=$((pass+1)); echo "ok    push barra commit com credito, venha de onde vier";; *) fail=$((fail+1)); echo "FALHA push deixou subir commit com credito";; esac
case "$(pg "gh pr create --title x --body y")" in *deny*) pass=$((pass+1)); echo "ok    gh pr create tambem le os commits que vao subir";; *) fail=$((fail+1)); echo "FALHA gh pr create deixou passar";; esac
case "$(pg "git -C \"$PG/repo\" push" "$FH")" in *deny*) pass=$((pass+1)); echo "ok    git -C aponta o repositorio certo";; *) fail=$((fail+1)); echo "FALHA git -C nao leu o repositorio";; esac

# depois de reescrever o commit, o push passa
git commit -q --amend -m "fix: b"
[ -z "$(pg "git push")" ] && { pass=$((pass+1)); echo "ok    push limpo passa"; } || { fail=$((fail+1)); echo "FALHA push limpo foi barrado"; }

# branch nova sem upstream: compara com o branch padrao do remoto
git push -q origin main 2>/dev/null; git remote set-head origin main >/dev/null 2>&1
git checkout -q -b nova && echo c > c && git add c && git commit -q -m "feat: c" -m "$T"
case "$(pg "git push -u origin nova")" in *deny*) pass=$((pass+1)); echo "ok    branch sem upstream compara com o padrao do remoto";; *) fail=$((fail+1)); echo "FALHA branch nova sem upstream passou";; esac
cd "$REPO"

echo "--- stop-audit (extra, opt-in)"
SA="$REPO/extras/stop-audit/stop-audit.sh"
SAD="$FH/sa"; mkdir -p "$SAD/bin"
{ echo "#!/usr/bin/env bash"
  echo 'shift; printf "%s" "$1" > "$CAPTURE"; echo "$FAKE_VERDICT"'; } > "$SAD/bin/claude"
chmod +x "$SAD/bin/claude"
printf '{"type":"assistant","message":{"content":[{"type":"text","text":"resposta de teste"}]}}
' > "$SAD/tr.jsonl"
sa () { echo "{\"transcript_path\":\"$SAD/tr.jsonl\"}" | CAPTURE="$SAD/prompt.txt" FAKE_VERDICT="$1" CONCISE_CORE="$2" PATH="$SAD/bin:$PATH" HOME="$FH" bash "$SA"; }

# o auditor julga contra o nucleo embarcado, nao contra uma copia que envelhece
rm -f "$SAD/prompt.txt"
out=$(sa "linha ruim" "$REPO/skills/concise/hooks/core.md")
case "$out" in *systemMessage*linha*) pass=$((pass+1)); echo "ok    stop-audit avisa a violacao";;
                                   *) fail=$((fail+1)); echo "FALHA stop-audit aviso: $out";; esac
grep -q "first sentence" "$SAD/prompt.txt" 2>/dev/null && { pass=$((pass+1)); echo "ok    stop-audit julga contra o nucleo"; } || { fail=$((fail+1)); echo "FALHA stop-audit nao passou o nucleo"; }

# veredito OK nao interrompe ninguem
out=$(sa OK "$REPO/skills/concise/hooks/core.md")
[ -z "$out" ] && { pass=$((pass+1)); echo "ok    stop-audit cala quando esta OK"; } || { fail=$((fail+1)); echo "FALHA stop-audit falou com OK: $out"; }

# nucleo ausente: cai no resumo embutido em vez de morrer
rm -f "$SAD/prompt.txt"
out=$(sa "linha ruim" "$SAD/nao-existe.md")
grep -q "first sentence" "$SAD/prompt.txt" 2>/dev/null && { pass=$((pass+1)); echo "ok    stop-audit tem fallback sem o nucleo"; } || { fail=$((fail+1)); echo "FALHA stop-audit fallback"; }

echo "--- boas-vindas cita todo comando"
# O texto de boas-vindas do notices.sh e um mapa do plugin, e ele envelheceu
# calado quando o :handoff entrou. Todo arquivo em commands/ tem que aparecer
# nele, entao um comando novo quebra este teste em vez de sair do mapa.
for port in concise; do
  hj="$REPO/skills/$port/hooks/hooks.json"
  faltando=""
  for cmd in "$REPO/skills/$port/commands/"*.md; do
    n=$(basename "$cmd" .md)
    grep -q ":$n\b" "$hj" || faltando="$faltando $n"
  done
  [ -z "$faltando" ] && { pass=$((pass+1)); echo "ok    boas-vindas de $port cita os comandos"; } || { fail=$((fail+1)); echo "FALHA boas-vindas de $port nao cita:$faltando"; }
done

echo "--- comando aponta para secao que existe"
# Comando diz "siga a secao X das regras". Quando a secao e renomeada, a
# referencia envelhece calada e o comando manda ler o que nao existe mais —
# aconteceu tres vezes entre 1.32.0 e 1.41.0.
for port in concise; do
  secoes="$FH/secoes-$port.txt"
  sed -n 's/^###* //p' "$REPO/skills/$port/SKILL.md" | tr -d '\r' > "$secoes"
  mortas=""
  for f in "$REPO/skills/$port/commands/"*.md "$REPO/skills/$port/agents/"*.md; do
    while read -r s; do
      [ -n "$s" ] || continue
      grep -qxF "$s" "$secoes" || mortas="$mortas $(basename "$f"):\"$s\""
    done <<EOF
$(perl -CSD -0777 -ne 'while (/"([^"]+)"\s+section|seção\s+"([^"]+)"/g) { my $s=($1//$2); $s =~ s/\s+/ /g; print "$s\n" }' "$f")
EOF
  done
  [ -z "$mortas" ] && { pass=$((pass+1)); echo "ok    referencias de secao em $port existem"; } || { fail=$((fail+1)); echo "FALHA secao morta em $port:$mortas"; }
done

echo "--- frontmatter de comando parseia"
# Valor de frontmatter comecando em `[` e uma sequencia YAML, e um crase
# abrindo item e token reservado: o parser desiste e o comando carrega com
# metadata vazia — sem descricao e sem dica de argumento na lista de comandos,
# calado. Foi assim que /concise:pr e :commit ficaram sem descricao.
for port in concise; do
  cruas=$(grep -l -E '^(description|argument-hint): \[' "$REPO/skills/$port/commands/"*.md 2>/dev/null | while read -r f; do basename "$f"; done | tr '\n' ' ')
  [ -z "$cruas" ] && { pass=$((pass+1)); echo "ok    frontmatter de $port sem sequencia crua"; } || { fail=$((fail+1)); echo "FALHA frontmatter nao citado em $port: $cruas"; }
  invalidos=""
  for f in "$REPO/skills/$port/SKILL.md" "$REPO/skills/$port/"{commands,agents,output-styles}/*.md; do
    awk 'NR==1 { if ($0 != "---") exit 1; next }
         /^---$/ { closed=1; exit }
         /^description: .+/ { description=1 }
         END { exit !(description && closed) }' "$f" || invalidos="$invalidos $(basename "$f")"
  done
  [ -z "$invalidos" ] && { pass=$((pass+1)); echo "ok    frontmatter de $port abre o arquivo"; } || { fail=$((fail+1)); echo "FALHA frontmatter ausente ou cercado:$invalidos"; }
  awk '/^---$/ { n++; next } n==1' "$REPO/skills/$port/agents/audit.md" | grep -qx 'tools: Read, Grep, Glob' &&
    { pass=$((pass+1)); echo "ok    auditor restrito a leitura"; } || { fail=$((fail+1)); echo "FALHA ferramentas do auditor fora do frontmatter"; }
done

echo "--- route-hint: a PR passa pelo comando que a escreve"
# Uma negativa por sessao, e a segunda chamada passa. Se ela nao passasse, o
# hook viraria parede: a sessao nao teria como abrir PR nenhuma.
R="$REPO/skills/concise/hooks/route-hint.sh"
RT="$FH/rt"; mkdir -p "$RT"
r () { # nome, esperado(deny|allow), stdin
  out=$(printf '%s' "$3" | HOME="$FH" TMPDIR="$RT" bash "$R" "MOTIVO" .concise-no-route-hint)
  got=allow; case "$out" in *permissionDecision*) got=deny;; esac
  if [ "$got" = "$2" ]; then pass=$((pass+1)); printf 'ok    %-46s %s\n' "$1" "$got"
  else fail=$((fail+1)); printf 'FALHA %-46s esperado=%s obtido=%s\n' "$1" "$2" "$got"; fi
}
r "gh pr create avisa na primeira vez"   deny  '{"session_id":"s1","command":"gh pr create --fill"}'
r "a segunda chamada da sessao passa"    allow '{"session_id":"s1","command":"gh pr create --fill"}'
r "outra sessao avisa de novo"           deny  '{"session_id":"s2","command":"gh pr create --title x --body y"}'
r "gh pr edit --body avisa"              deny  '{"session_id":"s3","command":"gh pr edit 77 --body-file b.md --body x"}'
r "gh pr view nao avisa"                 allow '{"session_id":"s4","command":"gh pr view 77 --json body"}'
r "git push nao avisa"                   allow '{"session_id":"s5","command":"git push -u origin minha-branch"}'
# O /concise:pr create abre a PR com o proprio gh pr create: negar essa chamada
# mandaria a sessao rodar o comando em que ela ja esta.
printf '%s\n' '{"type":"user","message":{"role":"user","content":"<command-message>concise:pr</command-message>\n<command-name>/concise:pr</command-name>\n<command-args>create</command-args>"}}' > "$RT/com-pr.jsonl"
printf '%s\n' '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"concise:pr","args":"create"}}]}}' > "$RT/skill-pr.jsonl"
printf '%s\n' '{"type":"attachment","skills":["concise:plan","concise:pr"]}' '{"type":"user","message":{"role":"user","content":"abre a PR"}}' > "$RT/sem-pr.jsonl"
r "depois de /concise:pr passa direto"   allow "{\"session_id\":\"s8\",\"transcript_path\":\"$RT/com-pr.jsonl\",\"command\":\"gh pr create --fill\"}"
r "depois da skill concise:pr passa"     allow "{\"session_id\":\"s9\",\"transcript_path\":\"$RT/skill-pr.jsonl\",\"command\":\"gh pr create --fill\"}"
r "lista de skills no transcript avisa"  deny  "{\"session_id\":\"s10\",\"transcript_path\":\"$RT/sem-pr.jsonl\",\"command\":\"gh pr create --fill\"}"
# Uma marca por sessao e nada mais as apaga: a de mais de um dia sai.
touch -t 202001010000 "$RT/concise-route-hint.velha"
r "sessao nova ainda avisa"              deny  '{"session_id":"s11","command":"gh pr create --fill"}'
[ -f "$RT/concise-route-hint.velha" ] && { fail=$((fail+1)); echo "FALHA marca de mais de um dia ficou"; } || { pass=$((pass+1)); echo "ok    marca de mais de um dia sai"; }
[ -f "$RT/concise-route-hint.s11" ] && { pass=$((pass+1)); echo "ok    marca da sessao atual fica"; } || { fail=$((fail+1)); echo "FALHA marca da sessao atual sumiu"; }
touch "$FH/.claude/.concise-no-route-hint"
r "opt-out pelo arquivo de flag"         allow '{"session_id":"s6","command":"gh pr create --fill"}'
rm "$FH/.claude/.concise-no-route-hint"
out=$(printf '%s' '{"session_id":"s7","command":"gh pr create --fill"}' | HOME="$FH" TMPDIR="$RT" CONCISE_NO_ROUTE_HINT=1 bash "$R" "M" .concise-no-route-hint)
[ -z "$out" ] && { pass=$((pass+1)); echo "ok    opt-out pela variavel de ambiente"; } || { fail=$((fail+1)); echo "FALHA opt-out por variavel"; }

echo "--- estilo forcado: output style e lembrete por turno"
# O nucleo chega uma vez, no inicio da sessao, e sessao longa se afasta dele.
# Duas camadas seguram: o output style forcado vai no system prompt de toda
# request, e o lembrete entra do lado de cada mensagem. Se uma delas some, o
# estilo volta a depender da sorte — entao as duas quebram teste aqui.
TR="$REPO/skills/concise/hooks/turn-reminder.sh"
ok () { pass=$((pass+1)); echo "ok    $1"; }
ko () { fail=$((fail+1)); echo "FALHA $1"; }
json_ok () { perl -MJSON::PP -e 'local $/; my $j = decode_json(<STDIN>); exit(($j->{hookSpecificOutput}{hookEventName} eq "UserPromptSubmit" && length $j->{hookSpecificOutput}{additionalContext}) ? 0 : 1)'; }

out=$(printf '%s' '{"prompt":"oi"}' | HOME="$FH" bash "$TR" "Resposta na primeira frase." .concise-no-turn-reminder)
printf '%s' "$out" | json_ok && ok "lembrete sai como additionalContext valido" || ko "lembrete nao e JSON de UserPromptSubmit: $out"
case "$out" in *"Resposta na primeira frase."*) ok "lembrete leva o texto recebido" ;; *) ko "lembrete perdeu o texto" ;; esac

out=$(printf '%s' '{}' | HOME="$FH" bash "$TR" 'aspas " e barra \ no texto' .concise-no-turn-reminder)
printf '%s' "$out" | json_ok && ok "aspas e barra no texto nao quebram o JSON" || ko "texto com aspas quebrou o JSON: $out"

# A regra de artefato custa atencao em todo turno que nao escreve um: ela so
# entra quando a palavra dela aparece no pedido.
out=$(printf '%s' '{"prompt":"escreva o card dessa mudanca"}' | HOME="$FH" bash "$TR" "X" .concise-no-turn-reminder 'card,tarefa|REGRA DE CARD.' 'desenh|REGRA DE DESENHO.')
case "$out" in
  *"REGRA DE CARD."*) case "$out" in *"REGRA DE DESENHO."*) ko "lembrete levou a regra de outro artefato" ;; *) ok "lembrete leva a regra do artefato pedido" ;; esac ;;
  *) ko "lembrete nao levou a regra do card: $out" ;;
esac
out=$(printf '%s' '{"prompt":"por que o total esta errado"}' | HOME="$FH" bash "$TR" "X" .concise-no-turn-reminder 'card,tarefa|REGRA DE CARD.')
case "$out" in *"REGRA DE CARD."*) ko "lembrete levou regra de card num pedido sem card" ;; *) ok "lembrete sem regra de artefato quando o pedido nao pede um" ;; esac
# O evento real traz o caminho do transcript e o cwd antes do prompt, e
# "Ricardo" contem "card": casando o JSON inteiro, a regra do card entrava em
# todo turno. So o campo prompt conta.
out=$(printf '%s' '{"session_id":"s","transcript_path":"C:\\Users\\Ricardo\\.claude\\t.jsonl","cwd":"C:\\Users\\Ricardo\\drawings","hook_event_name":"UserPromptSubmit","prompt":"vamos ver os hooks"}' | HOME="$FH" bash "$TR" "X" .concise-no-turn-reminder 'card|REGRA DE CARD.' ' draw|REGRA DE DESENHO.')
case "$out" in *REGRA*) ko "lembrete casou palavra no caminho, fora do prompt: $out" ;; *) ok "lembrete ignora caminho e cwd do evento" ;; esac
out=$(printf '%s' '{"prompt":"diz \"oi\" antes","depois":"card"}' | HOME="$FH" bash "$TR" "X" .concise-no-turn-reminder 'card|REGRA DE CARD.' 'antes|REGRA DE ANTES.')
case "$out" in *"REGRA DE CARD."*) ko "lembrete leu alem do fim do prompt: $out" ;; *"REGRA DE ANTES."*) ok "prompt termina na aspa que fecha, nao na escapada" ;; *) ko "lembrete perdeu o prompt com aspas escapadas: $out" ;; esac
# Palavra com espaco nas pontas casa a palavra inteira: " pr " nao casa em
# "sempre", " revis" nao casa em "previsao", e a PR no fim do pedido casa.
out=$(printf '%s' '{"prompt":"sempre a previsao"}' | HOME="$FH" bash "$TR" "X" .concise-no-turn-reminder ' pr |REGRA DE PR.' ' revis|REGRA DE REVISAO.')
case "$out" in *REGRA*) ko "palavra casou dentro de outra: $out" ;; *) ok "palavra com espaco nao casa dentro de outra" ;; esac
out=$(printf '%s' '{"prompt":"abre a PR."}' | HOME="$FH" bash "$TR" "X" .concise-no-turn-reminder ' pr |REGRA DE PR.')
case "$out" in *"REGRA DE PR."*) ok "palavra no fim do pedido, com pontuacao, casa" ;; *) ko "PR no fim do pedido nao casou: $out" ;; esac
# A palavra-chave acentuada nunca casa: a minusculizacao do bash anda byte a
# byte e quebra o acento. Toda palavra em hooks.json tem de ser ASCII.
for port in concise; do
  kw=$(perl -MJSON::PP -e 'binmode STDOUT, ":utf8"; local $/; my $j = decode_json(<STDIN>); my $c = $j->{hooks}{UserPromptSubmit}[0]{hooks}[0]{command}; print join "", $c =~ /'"'"'([^|'"'"']*)|/g' < "$REPO/skills/$port/hooks/hooks.json")
  if printf '%s' "$kw" | LC_ALL=C grep -q '[^ -~]'; then
    ko "palavra-chave do lembrete de $port fora do ASCII: $kw"
  else
    ok "palavras-chave do lembrete de $port sao ASCII"
  fi

# macOS ainda traz bash 3.2: ${var,,} e mapfile matam o hook inteiro la.
if grep -nE '${[A-Za-z_]+(,,|^^)}|mapfile|readarray|declare -A' "$REPO/skills/$port/hooks/"*.sh; then
  ko "hook de $port usa recurso de bash 4"
else
  ok "hooks de $port rodam em bash 3.2"
fi
done

touch "$FH/.claude/.concise-no-turn-reminder"
out=$(printf '%s' '{}' | HOME="$FH" bash "$TR" "X" .concise-no-turn-reminder)
[ -z "$out" ] && ok "lembrete: opt-out pelo arquivo de flag" || ko "lembrete ignorou a flag"
rm "$FH/.claude/.concise-no-turn-reminder"
out=$(printf '%s' '{}' | HOME="$FH" CONCISE_NO_TURN_REMINDER=1 bash "$TR" "X" .concise-no-turn-reminder)
[ -z "$out" ] && ok "lembrete: opt-out pela variavel de ambiente" || ko "lembrete ignorou a variavel"

for port in concise; do
  grep -q '"UserPromptSubmit"' "$REPO/skills/$port/hooks/hooks.json" &&
    grep -q 'hooks/turn-reminder.sh' "$REPO/skills/$port/hooks/hooks.json" &&
    ok "hooks.json de $port registra o lembrete" || ko "hooks.json de $port sem o lembrete"
  style=$(ls "$REPO/skills/$port/output-styles/"*.md)
  awk '/^---$/{n++; next} n==1' "$style" | tr -d '\r' | grep -qx 'force-for-plugin: true' &&
    ok "output style de $port e forcado" || ko "output style de $port nao tem force-for-plugin: true"
  # O output style e o hooks/core.md levam o mesmo nucleo por dois caminhos:
  # divergindo, a sessao segue um e a skill audita pelo outro.
  tr -d '\r' < "$style" | awk 'n<2 && /^---$/{n++; next} n>=2' | sed '/./,$!d' |
    diff -q - <(tr -d '\r' < "$REPO/skills/$port/hooks/core.md") >/dev/null &&
    ok "output style de $port igual ao hooks/core.md" || ko "output style de $port difere do hooks/core.md"
  # O card do marketplace e o que se le antes de instalar, e ja ficou para tras
  # da descricao do proprio plugin sem ninguem notar.
  mkt=$(perl -MJSON::PP -e 'binmode STDOUT, ":utf8"; local $/; my $j = decode_json(<STDIN>); print map { $_->{description} } grep { $_->{name} eq $ARGV[0] } @{$j->{plugins}}' "$port" < "$REPO/.claude-plugin/marketplace.json")
  plg=$(perl -MJSON::PP -e 'binmode STDOUT, ":utf8"; local $/; print decode_json(<STDIN>)->{description}' < "$REPO/skills/$port/.claude-plugin/plugin.json")
  [ -n "$mkt" ] && [ "$mkt" = "$plg" ] && ok "descricao do marketplace igual a do plugin $port" || ko "descricao do marketplace difere da do plugin $port"
  # O texto do lembrete viaja entre aspas simples na linha do hooks.json: um
  # apostrofo nele quebra o bash, e o hook falha calado em todo turno.
  cmd=$(perl -MJSON::PP -e 'binmode STDOUT, ":utf8"; local $/; my $j = decode_json(<STDIN>); print $j->{hooks}{UserPromptSubmit}[0]{hooks}[0]{command}' < "$REPO/skills/$port/hooks/hooks.json")
  out=$(printf '%s' '{}' | HOME="$FH" CLAUDE_PLUGIN_ROOT="$REPO/skills/$port" bash -c "$cmd" 2>/dev/null)
  printf '%s' "$out" | json_ok && ok "lembrete de $port roda pela linha do hooks.json" || ko "lembrete de $port quebra na linha do hooks.json: $out"
  # O lembrete era uma frase so, de mais de cem palavras, e a resposta copiava
  # o tom. Frase longa volta a quebrar aqui.
  longa=$(printf '%s' "$out" | perl -MJSON::PP -e 'local $/; my $t = decode_json(<STDIN>)->{hookSpecificOutput}{additionalContext}; for (split /(?<=\.)\s+/, $t) { my $n = () = /\S+/g; print "[$n] $_\n" if $n > 20 }')
  [ -z "$longa" ] && ok "lembrete de $port sem frase de mais de 20 palavras" || ko "lembrete de $port com frase longa: $longa"
  # E a brecha que deixava relatorio de trabalho feito passar de cinco linhas.
  case "$out" in *"if it must"*) ko "lembrete de $port deixa relatorio passar de cinco linhas" ;; *"finished work fits in five lines"*) ok "lembrete de $port segura relatorio em cinco linhas" ;; *) ko "lembrete de $port sem limite para relatorio: $out" ;; esac
  # A regra do card so vale se a palavra do pedido real a dispara pela linha
  # que o plugin carrega.
  out=$(printf '%s' '{"prompt":"escreva o card dessa mudanca"}' | HOME="$FH" CLAUDE_PLUGIN_ROOT="$REPO/skills/$port" bash -c "$cmd" 2>/dev/null)
  case "$out" in *"If this turn writes a card"*) ok "lembrete de $port leva a regra do card no pedido de card" ;; *) ko "lembrete de $port nao levou a regra do card: $out" ;; esac
  # Palavra dentro de outra puxava regra alheia: discard levava a do card e
  # preview a do comentario. E o plural de PR nao levava a da PR.
  for p in "discard the changes" "que tissue" "abre o preview" "cardinalidade da tabela"; do
    out=$(printf '{"prompt":"%s"}' "$p" | HOME="$FH" CLAUDE_PLUGIN_ROOT="$REPO/skills/$port" bash -c "$cmd" 2>/dev/null)
    case "$out" in *"If this turn writes"*) ko "lembrete de $port puxou regra em \"$p\"" ;; *) ok "lembrete de $port sem regra em \"$p\"" ;; esac
  done
  out=$(printf '%s' '{"prompt":"abre as PRs e move os cards"}' | HOME="$FH" CLAUDE_PLUGIN_ROOT="$REPO/skills/$port" bash -c "$cmd" 2>/dev/null)
  case "$out" in *"writes a card"*"writes a PR description"*) ok "lembrete de $port casa o plural de PR e de card" ;; *) ko "lembrete de $port perdeu o plural: $out" ;; esac
  # Cada artefato tem uma regra so: dois conjuntos quase iguais ja mandaram a
  # regra do desenho e a do comentario duas vezes no mesmo turno.
  out=$(printf '%s' '{"prompt":"desenhe o diagrama, faz o review do commit e abre a PR"}' | HOME="$FH" CLAUDE_PLUGIN_ROOT="$REPO/skills/$port" bash -c "$cmd" 2>/dev/null)
  dup=""
  for r in "no line past 72" "anchor path above the comment" "three sections under headers" "six lines at most"; do
    n=$(printf '%s' "$out" | grep -o "$r" | wc -l | tr -d ' ')
    [ "$n" = 1 ] || dup="$dup [$r]=$n"
  done
  [ -z "$dup" ] && ok "lembrete de $port leva cada regra de artefato uma vez" || ko "lembrete de $port com regra repetida ou ausente:$dup"
done

echo "--- skill: arquivos de referencia e tamanho"
# Cada superficie que sai da conversa mora num arquivo proprio, que a skill e
# os comandos citam. Nome errado deixa o comando sem regra, calado. E o
# SKILL.md chegou a 696 linhas: acima de 500 a recomendacao e dividir, e
# depois da compactacao so os primeiros 5.000 tokens da skill voltam.
for port in concise; do
  dir="$REPO/skills/$port"
  faltando=""
  for ref in $(grep -oh 'refer[a-z]*/[a-z-]*\.md' "$dir/SKILL.md" "$dir/commands/"*.md "$dir/agents/"*.md | sort -u); do
    [ -f "$dir/$ref" ] || faltando="$faltando $ref"
  done
  for f in "$dir"/refer*/*.md; do
    n="$(basename "$(dirname "$f")")/$(basename "$f")"
    grep -q "$n" "$dir/SKILL.md" || faltando="$faltando fora-da-skill:$n"
  done
  [ -z "$faltando" ] && ok "referencias de $port existem e a skill cita todas" || ko "referencias de $port:$faltando"
  linhas=$(wc -l < "$dir/SKILL.md" | tr -d ' ')
  [ "$linhas" -le 500 ] && ok "SKILL.md de $port com $linhas linhas" || ko "SKILL.md de $port passou de 500 linhas: $linhas"
done

echo "--- harness dos evals (claude falso)"
# O run.sh passou a rodar os casos em paralelo. Duas coisas que paralelismo
# quebra calado: a ordem do relatorio e o abort quando o CLI morre.
EV="$FH/ev"; mkdir -p "$EV"
printf '#!/usr/bin/env bash\nif [ "$1" = "--help" ]; then echo "--append-system-prompt-file"; exit 0; fi\necho resposta\necho PASS\n' > "$EV/ok"
printf '#!/usr/bin/env bash\nif [ "$1" = "--help" ]; then echo "--append-system-prompt-file"; exit 0; fi\nexit 0\n' > "$EV/vazio"
chmod +x "$EV/ok" "$EV/vazio"

esperado=$(ls "$REPO/evals/cases/"*.md | while read -r c; do basename "$c" .md; done)
obtido=$(CLAUDE_BIN="$EV/ok" bash "$REPO/evals/run.sh" 2>/dev/null | sed -n 's/^PASS  //p')
[ "$esperado" = "$obtido" ] && { pass=$((pass+1)); echo "ok    evals reportam em ordem de arquivo"; } || { fail=$((fail+1)); echo "FALHA ordem do relatorio dos evals"; }

CLAUDE_BIN="$EV/vazio" bash "$REPO/evals/run.sh" >/dev/null 2>&1
[ "$?" -eq 3 ] && { pass=$((pass+1)); echo "ok    evals abortam com CLI mudo"; } || { fail=$((fail+1)); echo "FALHA evals nao abortaram com CLI mudo"; }

# PLUGIN=1 carrega o plugin so na resposta: um juiz com o plugin daria a nota
# com a regra na mao. E o HOME de rascunho e o que impede os hooks de gravar
# estado no ~/.claude de quem roda.
cat > "$EV/grava" <<EOF
#!/usr/bin/env bash
if [ "\$1" = "--help" ]; then echo "--append-system-prompt-file"; exit 0; fi
case " \$* " in *" --append-system-prompt-file "*) papel=resposta ;; *) papel=juiz ;; esac
case " \$* " in *" --plugin-dir "*) com="com plugin" ;; *) com="sem plugin" ;; esac
case "\$HOME" in "$HOME") casa="HOME real" ;; *) casa="HOME de rascunho" ;; esac
echo "\$papel \$com, \$casa" >> "$EV/chamadas"
echo resposta
echo PASS
EOF
chmod +x "$EV/grava"
PLUGIN=1 CLAUDE_CONFIG_DIR="$FH/cfg" ONLY=01 RESPONSES="$EV/respostas" CLAUDE_BIN="$EV/grava" bash "$REPO/evals/run.sh" >/dev/null 2>&1
[ "$(sort -u "$EV/chamadas" 2>/dev/null | tr '\n' ';')" = "juiz sem plugin, HOME real;resposta com plugin, HOME de rascunho;" ] &&
  ok "PLUGIN=1 carrega o plugin so na resposta, com HOME de rascunho" || ko "PLUGIN=1 vazou o plugin para o juiz ou o HOME real para a resposta"
[ -s "$EV/respostas/01-factual-question.1.txt" ] && ok "RESPONSES guarda cada resposta" || ko "RESPONSES nao guardou a resposta"
env -u CLAUDE_CONFIG_DIR PLUGIN=1 ONLY=01 CLAUDE_BIN="$EV/ok" bash "$REPO/evals/run.sh" >/dev/null 2>&1
[ "$?" -eq 2 ] && ok "PLUGIN=1 recusa rodar sem config isolada" || ko "PLUGIN=1 rodou sem config isolada"

# Rodada barata: ONLY com varios numeros, MIN_RUNS que para quando as tentativas
# concordam com a rodada salva, RESULTS que so reescreve as linhas que rodaram,
# e COMPARE que roda tudo e sai com 1 quando um caso piora.
obtido=$(ONLY=1,03 CLAUDE_BIN="$EV/ok" bash "$REPO/evals/run.sh" 2>/dev/null | sed -n 's/^PASS  //p' | tr '\n' ' ')
[ "$obtido" = "01-factual-question 03-false-premise " ] && ok "ONLY aceita varios numeros" || ko "ONLY com varios numeros: $obtido"
cat > "$EV/conta" <<EOF
#!/usr/bin/env bash
if [ "\$1" = "--help" ]; then echo "--append-system-prompt-file"; exit 0; fi
case " \$* " in *" --append-system-prompt-file "*) echo resposta >> "$EV/contadas" ;; esac
echo resposta
echo "\${VEREDITO:-PASS}"
EOF
chmod +x "$EV/conta"
printf '01-factual-question\t5\t5\r\nzz-outro\t1\t5\r\n' > "$EV/salvo.tsv"
: > "$EV/contadas"
RUNS=5 MIN_RUNS=2 ONLY=01 COMPARE="$EV/salvo.tsv" RESULTS="$EV/salvo.tsv" CLAUDE_BIN="$EV/conta" bash "$REPO/evals/run.sh" >/dev/null 2>&1
[ "$(grep -c . "$EV/contadas")" = 2 ] && ok "MIN_RUNS para em 2 quando concorda com a rodada salva" || ko "MIN_RUNS nao parou: $(grep -c . "$EV/contadas") respostas"
[ "$(tr '\t\n' ' ;' < "$EV/salvo.tsv")" = "01-factual-question 2 2;zz-outro 1 5;" ] && ok "RESULTS reescreve so as linhas que rodaram" || ko "RESULTS: $(tr '\t\n' ' ;' < "$EV/salvo.tsv")"
printf '01-factual-question\t5\t5\n' > "$EV/salvo.tsv"
: > "$EV/contadas"
saida=$(RUNS=5 ONLY=01 COMPARE="$EV/salvo.tsv" VEREDITO=FAIL CLAUDE_BIN="$EV/conta" bash "$REPO/evals/run.sh" 2>/dev/null); rc=$?
[ "$rc" -eq 1 ] && printf '%s\n' "$saida" | grep -q "^worse   01-factual-question  5/5 -> 0/2" && [ "$(grep -c . "$EV/contadas")" = 2 ] &&
  ok "COMPARE para quando o que falta nao muda o veredito, e sai com 1" || ko "COMPARE com piora: rc=$rc, $(grep -c . "$EV/contadas") respostas"
printf '01-factual-question\t0\t5\n03-false-premise\t5\t5\n' > "$EV/salvo.tsv"
: > "$EV/contadas"
saida=$(RUNS=5 MIN_RUNS=2 ONLY=01,03 WORSE_ONLY=1 COMPARE="$EV/salvo.tsv" CLAUDE_BIN="$EV/conta" bash "$REPO/evals/run.sh" 2>/dev/null); rc=$?
[ "$rc" -eq 0 ] && printf '%s\n' "$saida" | grep -q "^0 worse, 1 not worse, 1 skipped as unable to get worse" && [ "$(grep -c . "$EV/contadas")" = 2 ] &&
  ok "WORSE_ONLY pula o caso que nao tem como piorar" || ko "WORSE_ONLY: rc=$rc, $(grep -c . "$EV/contadas") respostas"
WORSE_ONLY=1 ONLY=01 CLAUDE_BIN="$EV/ok" bash "$REPO/evals/run.sh" >/dev/null 2>&1
[ "$?" -eq 2 ] && ok "WORSE_ONLY recusa rodar sem COMPARE" || ko "WORSE_ONLY rodou sem COMPARE"

# Um conjunto em evals/sets/ vira ONLY; um numero sem caso sumiria calado.
esperado=$(sed 's/#.*//' "$REPO/evals/sets/core.txt" | tr -d '\r' | grep -o '[0-9][0-9]' | sort | tr '\n' ' ')
obtido=$(SET=core CLAUDE_BIN="$EV/ok" bash "$REPO/evals/run.sh" 2>/dev/null | sed -n 's/^PASS  \([0-9][0-9]\)-.*/\1/p' | tr '\n' ' ')
[ -n "$esperado" ] && [ "$esperado" = "$obtido" ] && ok "SET=core roda exatamente os casos da lista" || ko "SET=core: esperado [$esperado], obtido [$obtido]"
faltando=""
for n in $(sed 's/#.*//' "$REPO"/evals/sets/*.txt | tr -d '\r' | grep -o '[0-9][0-9]'); do
  ls "$REPO"/evals/cases/"$n"-*.md >/dev/null 2>&1 || faltando="$faltando $n"
done
[ -z "$faltando" ] && ok "todo numero em evals/sets/ tem caso" || ko "numeros sem caso em evals/sets/:$faltando"
# os casos de comando so fazem sentido com o plugin: sem ele, o prompt e um comando desconhecido
out=$(cd "$REPO" && CASES=commands bash evals/run.sh 2>&1); rc=$?
[ "$rc" = 2 ] && case "$out" in *"needs PLUGIN=1"*) true;; *) false;; esac && { pass=$((pass+1)); echo "ok    CASES=commands recusa rodar sem o plugin"; } || { fail=$((fail+1)); echo "FALHA CASES=commands sem plugin: rc=$rc $out"; }
n=$(ls "$REPO/evals/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
bad=$(for f in "$REPO/evals/commands/"*.md; do awk '/^## Prompt/{getline; while ($0=="") getline; print; exit}' "$f" | grep -qE '^/concise:[a-z]+' || basename "$f"; done)
[ "$n" -ge 6 ] && [ -z "$bad" ] && { pass=$((pass+1)); echo "ok    casos de comando abrem com /concise:"; } || { fail=$((fail+1)); echo "FALHA casos de comando: n=$n sem comando: $bad"; }

echo "===== $pass ok, $fail falhas"
[ "$fail" -eq 0 ]
