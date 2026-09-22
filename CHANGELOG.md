# Changelog

Every `version` bump of the plugin gets an entry here. The number is what
propagates a release: the self-update hook and `claude plugin update` both
compare versions, so a change without a bump reaches nobody — and a bump
without an entry tells nobody what it brought.

## 1.91.0 — 2026-09-22

O comentário de review sai em frases curtas e com as palavras de quem usa o
sistema, e leva só o que bloqueia o merge.

- **Frases curtas, uma ideia cada**, cerca de 40 palavras no total. Antes
  eram uma ou duas frases longas, cheias de ressalvas.
- **A segunda review abre com o que a primeira pediu:** "Os 3 pontos
  anteriores estão corrigidos. Falta um que bloqueia o merge."
- **O problema vem como quem usa vê**, com a causa depois de "porque", e o
  código é chamado pelo que faz: "esta busca", e não o nome da função.
- **O caminho do arquivo vai acima do comentário**, como o lugar de postar, e
  sai do meio da frase.
- **O que não bloqueia vai num comentário próprio, na linha dele.** O que o
  revisor rodou vai na resposta para o usuário, e não no comentário.
- **Não medido:** os evals não rodaram.

## 1.90.0 — 2026-09-21

Comentário e mensagem ficam mais curtos e passam a soar como alguém escreveu
para alguém, e não como um relatório.

- **Uma ou duas frases, abaixo de 40 palavras.** Três linhas continuam sendo o
  teto, e o comando faz uma segunda passada só para cortar.
- **Voz de mensagem**: frases comuns, "você" e "a gente", no idioma da thread,
  abrindo na afirmação e fechando no pedido. Rótulos como `Issue:` e
  `Fix:`, negrito, listas e títulos ficam para documento.
- **Se bloqueia, dito em palavras comuns** dentro da frase, como "precisa mudar
  antes do merge".
- A referência traz um par de exemplos, voz de relatório contra voz de
  mensagem, e o lembrete de cada turno leva a mesma regra.

## 1.89.0 — 2026-09-15

O guarda de crédito passa a conferir o commit como o git o guardou, na hora do
push, e não só o texto do comando que o criou.

- **Antes de `git push`, `gh pr create` e `glab mr create`, o guarda lê a
  mensagem de cada commit que vai subir.** Uma assinatura de agente que entrou
  por script, editor ou arquivo apagado depois é barrada ali, com o commit
  apontado.
- **O intervalo é o que o push manda**: depois do upstream da branch, ou do
  branch padrão do remoto quando a branch ainda não tem upstream.
- As três lacunas desta semana vieram do mesmo lugar — ler o comando em vez do
  resultado. A leitura do comando continua, e o push fecha o que ela deixar
  passar.

## 1.88.1 — 2026-09-15

- **O guarda de crédito barra a assinatura que um patch do Codex adiciona.** O
  Codex edita arquivo por patch, e a linha adicionada chega com `+` na frente,
  que o guarda não reconhecia.
- **O README ensina a instalar no Codex**, e descreve o self-update como ele é
  desde a 1.79.0: a cada seis horas, com nova tentativa na sessão seguinte a
  uma falha.

## 1.88.0 — 2026-09-15

O plugin passa a funcionar também no Codex, que lê este mesmo marketplace e os
mesmos hooks. Nada disso rodou ainda num Codex de verdade: segue a
documentação dele, e os testes simulam o ambiente.

- **No Codex, o núcleo entra no início da sessão**, porque lá não existe o
  estilo de saída forçado que o carrega no Claude Code.
- **O lembrete de cada mensagem e o guarda de crédito** funcionam como no
  Claude Code, sem mudança.
- **Self-update, a nota de boas-vindas e o aviso para `/concise:pr` ficam
  quietos no Codex**: ele atualiza plugins sozinho e não tem comandos de
  plugin.
- **Um manifesto próprio do Codex** acompanha o do Claude Code em nome e
  versão, e um teste falha quando os dois se separam.
- Os comandos e o agente de auditoria ainda não chegam ao Codex.

## 1.87.0 — 2026-09-15

O guarda de crédito passa a ler a mensagem de commit ou PR guardada num
arquivo cujo caminho usa variável — o jeito mais comum de um script passar o
texto.

- **`W=...; gh pr create --body-file "$W/pr.md"` agora é conferido**, assim
  como `export`, `~`, `$HOME` e, no PowerShell, `$W = ...` e `$env:`.
  Antes o guarda não achava o arquivo e deixava passar.
- **Uma variável que o comando não define e o ambiente não tem continua sem
  leitura**, sem inventar um caminho.
- Sete testes novos; os seis de leitura falham no guarda antigo.

## 1.86.1 — 2026-09-14

Os comandos, as referências e o agente de auditoria ficam mais curtos,
preservando as correções recentes do núcleo e dos hooks. O estilo de saída
e o comando `woman` voltam a ter metadados válidos; o auditor mantém suas
ferramentas restritas a leitura. Os arquivos gerados acompanham a refatoração.

## 1.86.0 — 2026-09-14

O guarda de crédito deixava passar três jeitos comuns de publicar texto, e o
self-update ficava calado quando não havia como atualizar.

- **Um commit com opção antes do verbo, como `git -c k=v commit`, agora é
  conferido.** Antes o guarda só reconhecia `git commit` e `git -C dir commit`.
- **Tag anotada e GitLab entram**: `git tag -m`, e `glab` criando ou editando
  MR, issue, nota ou release.
- **Sem o `claude` no PATH, o self-update deixa a marca de falha**, e o aviso
  semanal passa a dizer que a cópia não está atualizando.

## 1.85.0 — 2026-09-14

A atualização automática volta a checar logo depois de ser cortada, e uma
checagem cortada passa a contar como falha.

- **A trava dura dois minutos.** Uma sessão que termina antes da checagem a
  mata no meio, e a trava ficava. Por uma hora, nenhuma checagem rodava. Um
  `claude -p` que dura um segundo reproduz isso.
- **Checagem cortada conta como falha.** Antes ela não gravava nada, e o aviso
  semanal nunca aparecia.
- Cinco testes novos, e dois deles falham no código anterior.

## 1.84.0 — 2026-09-14

O lembrete de cada mensagem fica curto e em frases simples, e o relatório de
trabalho feito também cabe em cinco linhas.

- **Frases curtas.** O lembrete era uma frase só, de 196 palavras, e as
  respostas copiavam o tom. Agora nenhuma frase passa de 20 palavras.
- **Sem brecha para relatório.** Sai a exceção que deixava o relatório passar
  de cinco linhas. Ele agrupa o trabalho, e os detalhes esperam ser pedidos.
- **Linguagem simples a cada mensagem.** "Palavras simples" e "uma ideia por
  frase" estavam só no núcleo, e agora vêm junto de cada pedido.
- Dois testes novos quebram a suíte se a frase longa ou a brecha voltarem.
- **Não medido:** os evals não rodaram. A exceção tinha entrado na 1.70.0
  pelo caso 18, que pode voltar a cair.

## 1.83.0 — 2026-09-14

O guarda de crédito passa a ler a mensagem que vem de arquivo em qualquer
forma, o `/concise:pr create` abre a PR sem ser barrado, e o lembrete para de
puxar regra por palavra dentro de outra.

- **Arquivo entre aspas é lido.** `git commit -F "msg.txt"` e
  `gh pr create --body-file 'b.md'` passavam com a assinatura dentro, porque
  só o caminho sem aspas era aberto. Também são lidos `$(cat msg.txt)`,
  `Get-Content msg.txt` e todos os arquivos da chamada, não só o primeiro.
- **`gh pr merge` é checado**, porque a mensagem do squash vai para o
  histórico da `main`.
- **O `/concise:pr create` passa direto.** O comando abre a PR com o próprio
  `gh pr create`, e o aviso negava essa chamada mandando rodar o comando em
  que a sessão já estava.
- **As marcas do aviso de PR com mais de um dia são apagadas.** Ficava uma
  por sessão na pasta temporária, para sempre.
- **Card, issue e review casam a palavra inteira:** "discard" e
  "cardinalidade" não puxam mais a regra do card, nem "preview" a do
  comentário. "PRs" passa a puxar a regra da PR.
- Dezoito testes novos, e catorze deles falham no código anterior.

## 1.82.0 — 2026-09-14

A regra de artefato do lembrete passa a entrar só quando o pedido fala do
artefato, e não quando a pasta ou o nome do usuário contém a palavra.

- **Só o texto do pedido é lido.** O evento também traz o caminho da conversa
  e a pasta aberta, e quem se chama Ricardo recebia a regra do card em todo
  turno, porque o nome contém "card".
- **Cada artefato tem uma regra só.** Card, comentário, PR e desenho vinham
  duas vezes, com texto quase igual, no mesmo turno.
- **A palavra casa inteira:** PR não casa em "sempre", revisão não casa em
  "previsão", e desenho não casa em "withdraw". "Mensagem" e "fluxo" saem da
  lista, porque casavam em quase todo pedido.
- Cinco testes novos cobrem o evento real, as aspas no pedido, a palavra
  inteira e a regra repetida.

## 1.81.0 — 2026-09-14

O guarda de crédito passa a valer também para arquivo escrito e card criado
pelo quadro, e não só para o que sai pelo terminal.

- **Escrever um arquivo com a assinatura de agente é barrado**, assim como
  criar ou editar um card por uma ferramenta de quadro.
- **Citar a regra em prosa continua passando**: no arquivo, só a forma de
  assinatura é barrada — a linha de crédito abrindo a própria linha, ou o
  selo com o emoji ou o link.
- **A saída de emergência é a mesma**: `CONCISE_ALLOW_CREDIT=1` ou o arquivo
  de flag em `~/.claude`.
- Quatro testes novos cobrem arquivo, prosa, card e o registro do guarda.

## 1.80.0 — 2026-09-14

O lembrete de todo turno passa a cobrar o que o núcleo já pedia: o nome que o
leitor nunca vai digitar chega a ele como aquilo que faz.

- **Uma linha nova no lembrete**, ao lado da primeira frase e dos valores
  exatos, porque a regra no núcleo sozinha não estava pegando.
- **O caso 20, que mede isso, sai de 0 de 5 para 2 de 3** em três tentativas;
  06, 15, 22, 30 e 39 ficam dentro do ruído das mesmas três.

## 1.79.0 — 2026-09-14

O self-update checa de seis em seis horas e volta a tentar depois de uma
falha, no lugar de uma vez por dia com a falha carimbada junto.

- **A janela vira seis horas**, e `~/.claude/.concise-update-hours` troca esse
  número. Sete versões saíram num dia e quem checou de manhã ficava na
  primeira até o dia seguinte.
- **A falha deixa o carimbo como estava**: a sessão seguinte tenta de novo, em
  vez de esperar a janela inteira com a marca de uma tentativa que nunca
  chegou ao marketplace.
- **Os testes de hook passam a rodar no macOS além do Linux**, porque o hook
  usa as ferramentas que o usuário tiver.
- **O lembrete por turno volta a funcionar no macOS**: ele minusculizava o
  pedido com `${in,,}`, que é bash 4, e o bash 3.2 do macOS matava o hook
  antes de qualquer regra de artefato entrar.

## 1.78.0 — 2026-09-14

As dez linhas negadas que as versões 1.73.0 a 1.77.0 trouxeram para os
comandos voltam à forma afirmativa que o CONTRIBUTING pede.

- **A permissão diz o que autoriza**: a palavra `run` é a permissão inteira de
  commitar, e `create` a de abrir a PR.
- **A crença diz o que vale**: o card é lido por quem chega de fora da
  conversa, o palco é o assunto inteiro, um destino nomeado é endereço e quem
  avisa alguém é a palavra do usuário.
- **O portão entra no update depois de você conferir**, no lugar de dizer o
  que custa não conferir.
- `:draw` e `:woman` ficam fora: as negativas de `:woman` estão nos exemplos
  citados, que são dados.

## 1.77.0 — 2026-09-14

Os oito comandos que faltavam passam a dizer o que acreditam antes do que
fazem, como `/concise:commit`, `:pr`, `:card` e `:comment` já faziam.

- **`:status`, `:handoff`, `:decide`, `:plan`, `:trim`, `:audit`,
  `:release` e `:rewrite`** ganham crenças, desejos e intenções, e somam 39
  linhas a menos.
- **A regra que trava a ação sobe para o começo de cada um**: destino nomeado
  não autoriza avisar ninguém, código que roda fica como está, publicar a
  release é do usuário, e o passo 1 do plano espera aprovação.
- **Nenhuma regra sai** — cada comando manteve o que já pedia, incluindo as
  linhas **Missing:** e **Unknown:**.
- `:draw` e `:woman` ficam fora: são longos por causa dos exemplos, e cortar
  ali é outro trabalho.

## 1.76.0 — 2026-09-14

`/concise:comment` entra na série: crenças, desejos e intenções, de 47 para 47
linhas, com a regra de postar no topo em vez do último parágrafo.

- **Comentar uma linha que você não leu é palpite com `path:line` no crachá.**
- **Um destino nomeado só diz para onde o comentário iria**; quem publica é a
  palavra do usuário nesta conversa.
- **Nenhuma regra sai**: leitura do que se comenta, parada quando a linha está
  fora de alcance, tipo assumido como comentário de revisão, o que cada tipo
  acrescenta, contagem de três linhas, entrega com quatro crases e âncora
  acima de cada bloco, e as linhas **Missing:**.

## 1.75.0 — 2026-09-14

`/concise:card` fecha a série com `/concise:commit` e `/concise:pr`: crenças,
desejos e intenções, de 44 para 45 linhas, e a regra de criar sobe para o topo.

- **Quem lê o card não estava na conversa**, e um valor que ela não deu é um
  buraco, não algo a inventar.
- **Só o destino nomeado na invocação autoriza criar** — antes isso só
  aparecia na última linha.
- **Nenhuma regra sai**: valores exatos, dois cards viram um rascunho do
  primeiro, entrega com quatro crases quando o corpo traz bloco, busca no
  destino antes de criar, formulário do `.github/ISSUE_TEMPLATE/`, campos do
  destino, bloqueador ou pai ligado de verdade, e o relatório do que ficou no
  padrão.

## 1.74.0 — 2026-09-14

`/concise:pr` segue `/concise:commit` e passa a dizer o que acredita antes de
listar o que faz, de 54 para 45 linhas.

- **O comando tem crenças, desejos e intenções**, como as referências.
- **A permissão sobe para o começo**: só a palavra `create` digitada abre a PR.
- **Nenhuma regra sai**: base `origin/main` quando não vem ref, parada em zero
  commits sobre a base, template e card procurados, passo de teste mesmo sem
  tela, corte do que repete acima de vinte e cinco linhas, entrega cercada por
  quatro crases com as linhas **Missing:**, e o que impede `gh pr create`.

## 1.73.0 — 2026-09-14

`/concise:commit` passa a dizer o que acredita antes de listar o que faz, e
encolhe de 40 para 35 linhas sem perder regra nenhuma.

- **O comando segue a forma das referências**: crenças, desejos e intenções.
- **Nenhuma regra sai**: o palco vazio para o trabalho, a forma do título vinda
  do log, o ticket só quando a branch ou quem chamou deu, a entrega em bloco
  cercado, as duas mudanças sem relação com o `git restore --staged`, e o
  commit só na palavra `run`.

## 1.72.0 — 2026-09-14

The rules of each artifact now ride on the turn that writes one, instead of
sitting in the core where every other turn pays for them. Measured against no
style at all, the plugin goes from 132 to about 141 passing answers of 200.

- **The turn reminder carries the artifact rule the request asks for**: a card,
  a review comment, a PR description, a commit message or a drawing. The words
  of the prompt pick it, so a turn that writes none stays as short as before.
- **A card opens with its area**, gives current and expected state, numbered
  steps to reproduce a bug, the open question and a done criterion.
- **A review comment is three lines in one paragraph**, with the full anchor
  path and whether it blocks the merge, and no praise or sign-off.
- **A PR description keeps every path the reviewer opens** and drops the names
  they never type, each command in its own fence with the output it prints.
- **A drawing names what it did not measure**, and hangs each cost off its box.

The same rules were tried in the core first and left there four other cases
worse, with the total unmoved at 132 — the measurement is in
[`evals/README.md`](evals/README.md#last-full-measurement).

## 1.71.0 — 2026-09-14

Five rule changes that came out of measuring every eval case five times, with
and without the plugin. The plugin now does better than no style on 13 of the
40 cases, the same on 26, and worse on one, the report of finished work.

- **The first sentence carries the result**, not a bare "yes" or a count of
  the steps it took; the turn reminder says the same.
- **What waits on the reader's decision gets its own block**, now among the
  first rules, and a check that was not run is said as not run.
- **A PR title keeps the area prefix the log uses**, and a PR description gets
  three sections under headers; a commit title follows the log's shape again.
- **Two things joined by and, a semicolon or parentheses are two list items.**

## 1.70.0 — 2026-09-13

A background job that finishes and changes nothing else gets one line again,
and a report on finished work keeps its exact values.

- **The core's status rule is back to its 1.68.0 words**: "send only the
  delta since your last message". The 1.69.0 rewrite said "only what changed
  since the previous update", and the model counted the steps still waiting
  as a change. Eval case 40 passed 7 of 10 runs on 1.66.0 and 1.68.0, 1 of 5
  on 1.69.0, and 7 of 10 with the old sentence back; case 12, the other status
  case, passes 5 of 5 either way.
- **`SKILL.md` says the same** in its status row.
- **The turn reminder lets a report in the chat pass five lines** when its
  deliverables need them, keeps every exact value, and splits a line that
  names three parts. Eval case 18, a finished PDF stack, went from 0 of 8 runs
  to 3 of 5, every answer keeping the version, the size and the test counts.
  Case 37, the text of a settings screen, went from 4 of 8 to 1 of 5, which
  five runs can't separate from noise; worded without the "in the chat" limit,
  the same reminder took it to 0 of 8.

## 1.69.0 — 2026-09-13

The Portuguese port is gone, and the English plugin answers in the language
you write in.

- **`respostas-curtas` leaves the marketplace.** An installed copy stops
  updating, and after a week says its self-update is failing. Switch with:

  ```
  /plugin uninstall respostas-curtas@claude-skill-concise
  /plugin install concise@claude-skill-concise
  ```

- **Replies follow your language**: the core now says "Always respond in the
  language the user is using to communicate with you."
- **The core and the skill are rewritten shorter**, as plain lists.
- **The parity check goes with the second port.** `scripts/test-hooks.sh`
  keeps the two checks that still apply: the output style matches the core,
  and the marketplace card matches the plugin.

## 1.68.0 — 2026-09-13

The repository is now `RicardoAlbuquerquet/concise`. The old address
redirects, so an installed copy keeps updating, and nothing in the plugin
changes name: it still installs as `concise@claude-skill-concise`.

- **Links point at the new address**: both READMEs, `homepage` and
  `repository` in both `plugin.json`, and the generated `AGENTS.md`.
- **The manual install copies from `concise/`**, the folder `git clone` now
  creates.

## 1.67.0 — 2026-09-12

Asked to describe something, the reply still came back with the right
sentence and a paragraph of parts after it — every part true, none of it
asked for.

- **A description gets one sentence**, and a second only for bad news or a
  caveat that changes what the reader does; the rest waits to be asked.
- **The turn reminder carries that**, leaves fences out of its five lines,
  and asks for a choice's options in a table.

## 1.66.0 — 2026-09-12

Of 56 real replies measured with the style on, the median ran fifteen lines
and 11 fit in five. The rules that would have cut the rest lived in
`SKILL.md`, which loads only when the skill is invoked; the core and the turn
reminder, read on every turn, carried none of them — and the reminder closed
on keeping caveats.

- **A caveat, a risk or a pending item takes one line, said once**: it stays
  unsaid until it changes, the reader is about to act against it, or the work
  is handed over.
- **The plan for your next tool calls stays out of the reply**, and a
  background result arriving is a status update: only its delta.
- **A call that is yours gets made**: the why of your own choices waits to be
  asked, and a choice the reader may want to undo gets one line naming it.
- **The turn reminder gives a question, an explanation or a status update
  five lines at most**, and keeps a choice's options side by side and a line
  per deliverable. Describing a tool went from 9 lines to 5 or 6.
- **`scripts/test-hooks.sh` runs the reminder through its real `hooks.json`
  line**: an apostrophe in the text ends the single-quoted bash string, and
  the hook would fail silently on every turn.

## 1.65.0 — 2026-09-12

The budgets were targets with no floor under them, so a turn that had four
things to say printed four blocks and the reader skimmed all four. A long
answer is read diagonally, and the line that mattered is the one skipped.

- **Most turns land in five lines or fewer**, and past that it is the
  Always-keep list that bought the space — not the number of things you
  happen to know.
- **Everyday words, short sentences**: where a plainer word says the same
  thing, the plainer one wins, and a sentence that needs a second reading
  gets split.
- Both live in the core, so they arrive in the system prompt and in the
  session context, not only in the skill.

## 1.64.0 — 2026-09-12

The hardest message to answer is not a review comment. Someone close sends
three paragraphs about being exhausted, broke and humiliated, and every
instinct on the receiving end — fix it, put it in perspective, compare it to
something harder — makes it land worse. The rules invert there: nothing gets
solved, and the shortest reply is the coldest one.

- **`/concise:woman`, `/respostas-curtas:mulher`**: answers a heavy vent in
  two or three sendable blocks and ends on presence instead of advice. It
  never offers money, never ties what someone feels to a cycle or to
  hormones, and never claims to have understood.
- **Each port carries its own voice rules** rather than a translation of the
  other's: half of what keeps a draft from reading like a machine is specific
  to the language it is written in.
- **It drops the style and names a crisis line** when a message goes past
  exhaustion into not wanting to be here.

## 1.63.0 — 2026-09-12

A PR description written from these rules came out correct and unreadable. The
reference governed the shape — three sections, a bold label on every item, one
screenful — and left the vocabulary free, so the body filled up with names that
exist only inside the repo. The reviewer asked for the version in ordinary
words, and rewriting it by hand was the only way to get one.

- **The PR reference governs the words too**: a name that lives only inside
  the repo becomes what it does, and what the reviewer will run, open or
  approve keeps its name.
- Case `39-pr-body-speaks-plainly` measures it.

## 1.62.0 — 2026-09-11

Most rules were written as prohibitions — "never cut", "don't", "no header
over a lone paragraph" — and a model follows a positive instruction more
reliably than a negated one: the negation names the thing to avoid and leaves
the model to work out what to do instead. Every negation has an affirmative
form with the same truth value, and the plugin now uses that form.

- **"Never cut" is now "Always keep"** (PT: "Sempre fica") — in `SKILL.md`,
  the core, the turn reminder, and every command and reference that cites it.
- **The AI-credit ban is an authorship rule**: authorship of every artifact
  and every git action belongs to the user alone, so the commit, the PR, the
  task and the code carry the user's name only. The credit guard's deny
  message says the same.
- **Every prompt-facing file is written in affirmative commands** — the
  skill, the core, the six references, the thirteen commands, the audit agent
  and the hook strings, both ports. Quoted examples of bad output keep their
  wording, since they are data, and so do labels inside the drawings.
- **The handoff's trailing label is `Unknown:`** in EN and `Em aberto:` in
  PT, where it was `Não sei:`.

## 1.61.0 — 2026-09-11

Two eval cases kept failing the same way after the split. A PR body put its
test command in prose whenever the command had already been run, and a review
comment shortened its path to `retry.ts:88` — the exact form the reference's
own example used.

- **`references/pull-request.md` keeps the fence on a command you already
  ran**: the line saying you ran it sits beside the fence, never in its place.
- **The comment examples carry a whole path**, `api/src/auth/retry.ts:88`, in
  the reference and in the command, both ports.

## 1.60.0 — 2026-09-11

Every rule was still paid for three times: in `SKILL.md`, in the reference
file, and in the command that reads the file — plus a closing paragraph in
each command that listed every rule again as a self-audit.

- **A command holds only the procedure.** `pr`, `card`, `comment`, `commit`
  and `release` stop restating the reference they read and no longer demand
  the skill be invoked first: about 3,700 tokens for the five together, from
  about 7,300. The self-audit paragraph is one line in every command.
- **`draw` is written as beliefs, desires and intentions** around its four
  layouts: about 2,300 tokens, from 3,900, with no rule dropped.
- **`SKILL.md` states each rule once**, its reason left to the belief it
  follows from: 273 lines and about 4,700 tokens in EN — the whole file now
  inside the 5,000 a compaction brings back — and 275 lines and 6,200 in PT.
- **The core says once what has its own file**: the two bullets describing
  the surfaces and the commands become one — 1,143 tokens on every request in
  EN, from 1,284, and 1,451 in PT, from 1,636.
- **The turn reminder is one clause shorter**: 297 characters in EN and 305
  in PT, from 427 and 429. The skill and command descriptions Claude Code
  lists at startup are one line each.

## 1.59.0 — 2026-09-11

`SKILL.md` had outgrown what a skill should carry: 696 lines and about 13,600
tokens in EN, 17,700 in PT, against a recommended ceiling of 500 lines. And
after a compaction Claude Code brings back only the first 5,000 tokens of each
invoked skill, so Always cut, Never cut and Before sending — at the end of the
file — were the part a long session lost.

- **The ruleset is written as beliefs, desires and intentions**: what Claude
  holds true about the reader, the medium and itself; what every reply is for;
  and what it commits to on every turn, in order of precedence — the budgets,
  Never cut, Always cut and Before sending first.
- **`SKILL.md` keeps what applies to every reply**: 278 lines and about 5,100
  tokens in EN, 280 lines and 6,500 in PT. Those four intentions end at about
  3,100 tokens in EN and 3,900 in PT, inside what a compaction brings back.
- **Each text that leaves the conversation has its own file, in the same
  shape**: `references/pull-request.md`, `task.md`, `commit.md`,
  `changelog.md`, `comment.md` and `code.md` — in PT, `referencias/pr.md`,
  `tarefa.md`, `commit.md`, `changelog.md`, `comentario.md` and `codigo.md`.
  The command that writes each text reads its file through
  `${CLAUDE_PLUGIN_ROOT}`, and `decide` and `plan` point at the merged
  "Recommendations, choices and plans" section.
- **The core takes the same shape**: two beliefs and one desire above the
  intentions it already carried — about 145 tokens more on every request in
  EN, 1,139 to 1,284.
- **The checks follow the split**: the eval harness appends the reference
  files in skill mode, since a case can't open one; `check-parity.sh` compares
  each reference with its translation; `test-hooks.sh` fails when a cited
  reference is missing, a reference goes uncited, or `SKILL.md` passes 500
  lines.

## 1.58.0 — 2026-09-11

The style stopped at the edge of the conversation: no rule in it reached the
comments in the code Claude writes, or the text on the screens it builds.

- **`SKILL.md` gains "Text inside code and on screen"** (PT: "Texto no código
  e na tela"). A comment says what the code can't, and nothing about the edit;
  no commented-out code; a message names what failed, with the value; a screen
  says each thing once, a button is a verb, tone words go. What stays: the
  consequence of an irreversible action, a value the person decides with,
  where a result lands when the screen can't show it, the way out of an error,
  legally required text, and the accessible name. Two rows join the budgets
  table, and the line exempting code now says the words inside it are not.
- **The core carries it as one bullet**, so the forced output style applies it
  without the skill being invoked, and the turn reminder gains one clause: 427
  characters a turn in EN, up from 331, and 429 in PT, up from 328.
- **`/concise:trim`** (PT: `/respostas-curtas:enxugar`) cuts the dead text out
  of the files the branch changed, or the paths you name. It keeps directives,
  license headers and accessible names, changes a visible string together with
  the tests and locales that match it — or leaves it and says so — runs the
  repo's checks, and never commits.
- **Cases 36 and 37** grade the comments in a new search hook and the text of
  a privacy settings page.

## 1.57.0 — 2026-09-11

The plugin said the same thing too many times. Every session loaded the core
twice — in the forced output style and again from the `SessionStart` hook — and
`SKILL.md` stated several rules in three or four places.

- **The `SessionStart` hook stops printing the shipped core.** The forced
  output style already carries it in the system prompt; the hook now prints
  only the line naming the shell, and the core override when one exists. About
  560 words less at every session start, resume and compaction.
  `CONCISE_INJECT_CORE=1` brings the old behaviour back, for a Claude Code that
  ignores `force-for-plugin` or a session where another plugin's forced style
  loads first.
- **The core override now lands on top of the shipped core** rather than
  replacing it, since the style in the system prompt carries the shipped one.
- **`SKILL.md` is 1,282 words shorter in EN and 1,223 in PT, about 15%, with no
  rule dropped.** The rule about names lifted from the code was stated four
  times, the title rule three, the AI-credit ban three, the whole-path rule
  twice; the drawing craft now points at `/concise:draw`; "Before sending" stops
  re-deriving the rules above it; the PR section said its opening twice.
- **Three inject-core checks changed in `scripts/test-hooks.sh`**: the core is
  not printed by default, comes back under `CONCISE_INJECT_CORE=1`, and without
  an override the session gets the platform line alone.

## 1.56.0 — 2026-09-11

Claude kept drifting out of the style in long sessions. The core arrived once,
at session start, as context; the output style carrying the same core was
opt-in, one `/config` pick almost nobody made; and nothing restated the rules
after the first screen of the conversation.

- **The output style is forced on while the plugin is enabled.** Both ports set
  `force-for-plugin: true`, so the core lands in the system prompt of every
  request, and Claude Code reminds the model of an active style mid-conversation
  on its own. It overrides the output style the user picked — Explanatory,
  Learning, their own — and when another enabled plugin also forces one, the
  first loaded wins. Disabling the plugin is the way back.
- **A `UserPromptSubmit` hook restates the style beside every prompt**, as
  `additionalContext`: the model sees one line between the message and the
  history, the transcript shows nothing. 331 characters a turn in EN, 328 in
  PT, and about 65 ms through Git Bash on Windows — drained and escaped with
  bash builtins, because it runs before every prompt. Off with
  `CONCISE_NO_TURN_REMINDER=1` or `~/.claude/.concise-no-turn-reminder`.
- **The `SessionStart` core stays**, for the core override, the shell line, and
  any Claude Code too old to know the frontmatter key — which ignores it and
  leaves the style one pick away in `/config`.
- **`~/.claude/concise-core-override.md` now replaces only the hook's copy.**
  The forced output style carries the shipped core.
- **Nine new checks in `scripts/test-hooks.sh`**: the reminder's JSON, quote
  and backslash escaping, both opt-outs, the registration in both
  `hooks.json`, and `force-for-plugin` in both styles — deleting the key fails
  the suite. `check-parity.sh` compares `turn-reminder.sh` byte for byte and
  counts `UserPromptSubmit` in the hooks shape.

## 1.55.0 — 2026-08-26

A real PR body came back correct and unreadable: five deliverables as
two-and-three-line paragraphs wearing dashes, an unlabelled block of prose
parked between the two headers, and the "I could not run this" note collected
at the end as a trailing paragraph. The template the repo ships has only
`## O que mudou` and `## Como testar` — and the problem the PR solved, the one
part the reviewer cannot rebuild from the diff, had nowhere to go and went
nowhere.

- **Every deliverable is one line under a bold label** naming the surface the
  change landed on. That column of labels down the left edge is what the
  reviewer reads first; an item running past one line is two claims or one
  padded one.
- **Nothing floats between the sections.** A migration note, a risk, a value
  that came out different — each is a line under its own bold label inside the
  section it belongs to, never an unlabelled paragraph between two headers.
- **A template with no slot for the problem does not delete the problem**: it
  opens that template's first section, in a sentence or two, before what the
  header asks for.
- **What you checked instead of running a step goes in that step.** Gathered
  at the end as a paragraph about what did not happen, it reads as a
  disclaimer and gets skimmed as one.
- **All four are in `commands/pr.md` too**, including its pre-delivery
  checklist, since that is what actually writes the body.

## 1.54.0 — 2026-08-25

A reply that ends in a link kept going. The turn opened a pull request,
handed over the URL — and then spent two more paragraphs describing the
sections of the description the reader was one click from, and one praising a
hook of ours for firing exactly as designed. Every budget in the ruleset was
obeyed; nothing in it said the artifact is the answer.

- **A tour of the artifact you just delivered is cut.** A PR URL, a card, a
  file you wrote — that link is the answer, and the recap of what is inside it
  is read *before* the thing it summarises, so it costs the reader twice.
- **What survives the cut is what the reader would get wrong by not opening
  it**: a part you did not verify, a value that came out different from what
  was asked, a caveat they need before they act — in the reply even when the
  artifact carries it too.
- **Your own tooling behaving as designed is cut too.** A hook that fired, a
  retry that went through, a check green on the first try. News is the
  mechanism failing, or changing what the reader gets.
- **Both land in the injected core**, not only the skill — the session that
  produced the overlong reply had the core and not the full ruleset.
- **Eval case 35** is that turn: a PR opened, a hook that rejected the first
  push, and one test step that could not be run. It passes 3 of 3, after the
  first wording of the exemption cost the unrun step one run in three.

## 1.53.0 — 2026-08-25

Cards came out correct and unreadable: five paragraphs of prose with the done
criterion buried in the fourth and five code spans stacked in the first. The
rules said what a card must contain and what it must not wear, never how the
body is laid out.

- **The default layout is two paragraphs, then labelled lines.** Current
  behaviour, expected behaviour, two sentences each with a blank line between
  them — then **Where:**, **Done when:**, **Out of scope:**, **Repro:**,
  **Impact:**, **Reverts:**, each opening in bold on its own line, skipping
  the ones with nothing in them. Those labels are what a card is scanned for.
- **Two code spans in a prose paragraph, and no parenthesis inside a
  parenthesis.** The **Where:** line is exempt — holding the pointers is what
  it is for, and it is what keeps the opening paragraphs about behaviour
  instead of about files.
- **`Repro:` heads the numbered steps rather than swallowing them**, which is
  the collision the new label created and case 11 caught.
- **Eval case 34** is the real card that prompted this, with its five names,
  its reversal of an earlier decision and its out-of-scope values. It passes
  3 of 3.
- **Case 11 was already flaky at 1 of 3**, measured against the pre-change
  skill before crediting anything: packed repro, title opening on the product
  name. The layout rules took it to 2 of 3, and naming the board's areas in
  its facts took it to 3 of 3.

## 1.52.0 — 2026-08-24

The two surfaces that had no budget get one, and the shortest of them gets
the tightest. The commit body was the only surface in the ruleset without a
number at all — the three commits this repo wrote with the command carry 16,
19 and 23 lines of body, and every other commit in its log has none. A
comment had a number for card notes only.

- **Six lines is the ceiling, and no body at all is the common case.** A
  title that already says the why has nothing left to add, and most logs are
  almost entirely title-only.
- **What pushes a body over is named, because it is never a second reason**:
  the investigation retold, the list of what you ran, a file-by-file account,
  the release note written early. Each lands in the PR description, the test
  step or the changelog anyway, so in the commit it is the same text twice.
- In `SKILL.md` as a budget row of its own, in `commands/commit.md` as a
  count before delivering, and in the hook core — which is where a session
  reads it without invoking anything.
- **Eval case 32** hands the model an hour of investigation, two green
  commands and a written changelog line, and fails the message that keeps any
  of them. It passes 3 of 3, and cases 09 and 16 still do.
- **A comment is three lines at most, one is common, and it is the shortest
  thing here** — review comment, thread reply, note on a card, message to a
  person, all the same ceiling. It is written as a message to one person who
  is mid-task: no header, no table, no list, no second paragraph, no greeting
  and no sign-off. A point that needs structure needs a card or a paragraph
  in the PR, and the comment is the line pointing at it.
- **What a comment leaves out, it leaves out silently.** A note explaining
  why the praise or the detail didn't go in is longer than the thing it left
  out. That rule exists because eval case 33 caught the note twice in three
  runs; loosening the rubric instead would have graded away what the case is
  for.
- **Eval case 33** grades a blocking review comment with praise dangled in
  the facts on purpose. It passes 3 of 3, and case 25 still does.

## 1.51.0 — 2026-08-24

The rule from 1.50.0 only fires if the command runs, and nothing made it
obvious that it should. Two PRs in a row got a description written from
memory while `/concise:pr` sat there able to read the diff.

- **A second `PreToolUse` hook routes PR writing through the command.** The
  session's first `gh pr create` — or `gh pr edit --body` — is denied once,
  with a reason naming `/concise:pr` and how to open the PR with it. Repeat
  the call and it goes through: the failure is a description written from
  memory, not a PR being opened, and a hook that kept denying would be a wall
  the session could not leave. Same escapes as the credit guard:
  `CONCISE_NO_ROUTE_HINT=1`, or `touch ~/.claude/.concise-no-route-hint`.
- **What it cannot see is a PR opened in the browser**, and no plugin can. A
  repo whose PRs are opened on github.com puts the line in its own
  `PULL_REQUEST_TEMPLATE` instead — this one now does, in the comment at the
  top.
- **`/concise:pr` and `/concise:commit` were loading with no description and
  no argument hint at all**, in both ports, and had been since the hints were
  added. A backtick opening an item inside `argument-hint: [...]` is a
  reserved token in a YAML flow sequence, so the frontmatter failed to parse
  and every field was silently dropped — the command list showed the two
  commands bare. `claude plugin validate ./skills/concise` said so; nothing
  ran it. Every `argument-hint` in both ports is now a quoted string, which is
  what it was always meant to be, and a test fails the suite on the next
  unquoted one.
- **Ten offline tests**, including the one that matters: the second call in
  the same session passes. The hook suite goes from 46 to 56. `route-hint.sh`
  is byte-identical across the ports and `check-parity.sh` now enforces that
  for five scripts instead of four.

## 1.50.0 — 2026-08-24

The same report as 1.49.0, one surface further out: the PR descriptions this
command writes ran 57, 65 and 57 lines.

- **A PR description now has a size: one screenful, around twenty-five lines
  of prose**, with the fenced commands not counted — code and commands are
  exempt from every budget in this ruleset, and this one is no exception. It
  is a ceiling and not a target: a section folded into a sentence, a dropped
  caveat and two commands sharing one fence never pay for it.
- **What inflates them is stated where the rule is**: a deliverable said twice
  — once in the table and again in the prose under it — and a check you ran
  retold as a trip instead of reported as one line plus the output that proves
  it. The break-it sequence handed to the reviewer *to run* stays; it is a
  test step, not an account. In `SKILL.md` and in `commands/pr.md`, which
  gained the line count as the last thing it checks before delivering.
- **Eval case 31** grades a PR description against the ceiling, including that
  the cut never comes out of a caveat or a fence. It passes 3 of 3; it took
  four rewrites to get there, and three of them were the rubric. Both lessons
  are in `evals/README.md`: a case whose facts restate work that really landed
  here gets contradicted by the session's own git context, and an item that
  grades a shape has to say what makes it fail in something countable.
- **Case 10's rubric is fixed**, and it was flaky at 2 of 3 before any of this
  — measured against the pre-change skill to be sure the new ceiling was not
  the cause. It read "ends with a test step containing the exact command"
  literally, so the unverified part the ruleset requires after the command
  failed the case that asked for it. It passes 3 of 3 now.
- `commands/pr.md` goes from 87 to 98 lines, against the ~100 that
  `CONTRIBUTING.md` asks a command to justify. The four lines it added buy the
  ceiling, the said-once rule and the counted-lines check at the end.

## 1.49.0 — 2026-08-24

Both halves of one report: replies still ran long, and they were dense with
terms the reader had no use for.

- **A turn gets one budget, not one per thing it could say.** Every row of the
  budget table is per situation, so a reply that finished some work, mentions
  what it noticed on the way and adds background obeys all three rows and
  arrives three times too long. Each block after the first now has to be paid
  for by what it leaves the reader doing — deciding, running, no longer
  trusting something — and a block that leaves nothing gets one line or goes.
  In `SKILL.md` and in the hook core, which is where most sessions read it.
- **A technical term now faces "will the reader meet it?" before it faces the
  gloss.** The rule was "keep the precise term and gloss it by consequence",
  which reads as a licence to keep every term and explain each one — four
  glosses in a reply is both harder to read and longer. The term stays when
  they will type it, click it, read it on their own screen or approve changing
  it; otherwise the sentence says what the thing does and never names it.
- **One gloss per response is the ceiling.** A second term wanting its own
  explanation is the signal that the reply is carrying the shape of the
  investigation instead of the shape of the answer. The final pass in
  **Before sending** now counts them.
- **Dropping a term is not going vague**, and the skill says so where the rule
  lives: "the column stores the time in UTC" is exact without `timestamptz`;
  "there's a timezone thing" threw the information away and kept the length.
- **Two eval cases**, both aimed at what was reported: 29 grades a response
  that may explain at most one term out of four, and 30 grades a completed-work
  turn carrying one real finding and three inert observations. The suite goes
  from 28 to 30 cases. The rule → case map also gained the four rows it was
  missing for 25–28.

## 1.48.0 — 2026-08-22

- **The eval suite runs eight cases at a time instead of one.** It was 2N
  blocking API calls in a queue — 56 of them for 28 cases — which is the whole
  reason it took long enough to avoid. The cases share nothing, so the only
  thing the queue bought was the order of the report, and that is now restored
  at collection time: a parallel run reads exactly like a serial one.
  `JOBS=1` puts it back in a queue for a rate limit or a log you want to watch.
- **The judge runs on a fast model by default** (`JUDGE_MODEL`, Haiku 4.5). It
  matches a response against a rubric — it does not write — and it is half of
  every case. `JUDGE_MODEL=` empty puts it back on whatever `MODEL` is.
- **A dead CLI now reports one reason and a count**, not the same line
  repeated once per case in flight — which is what parallelism turns a single
  auth failure into.
- **Two offline tests guard the refactor**: the report comes out in filename
  order, and a mute CLI exits 3 instead of scoring silence. Both verified
  against the break they exist for. The hook suite goes from 44 to 46.

## 1.47.0 — 2026-08-22

- **A command pointing at a section that no longer exists now fails the
  suite.** Every `"<name>" section` reference in a command or agent has to
  match a `## <name>` heading in its port's `SKILL.md`. This is the class of
  error that appeared three times between 1.32.0 and 1.41.0 — a rule gets
  renamed or revoked and the files pointing at it go stale in silence.
  Verified against a real rename: turning `## Show the shape` into
  `## Draw the shape` turns the suite red naming `draw.md`. It runs offline,
  so it gates every PR.
- **Eval case 28 covers the one-hanging-note rule from 1.46.0**, which had no
  coverage: a four-hop flow with exactly one thing wrong, so a drawing that
  annotates all four fails. Case 27 could not carry it — that one has two
  costs by construction. The suite goes from 27 to 28 cases, and the hook
  suite from 42 to 44.

## 1.46.0 — 2026-08-22

- **One hanging note per drawing, and it sits on the finding.** Until now the
  rules asked for a label on every arrow and a cost on every hop, which can
  end in a drawing where everything is annotated — and where everything is
  annotated, nothing stands out. This is the first drawing rule that removes
  output rather than asking for more. Two boxes deserving the mark means two
  findings, and probably two drawings.
- **`?` is the one form for an unverified hop** — `webhook retried ×3 ?`. The
  rule already demanded the mark and never said what it looked like, so each
  drawing invented `(?)`, `[unverified]` or `~`, and the mark became the thing
  the reader had to decode.
- **The boxes use the words the surrounding prose uses.** A box reading
  `exporter` under a paragraph about "the export job" hands the reader two
  pictures to hold at once.
- **`CONTRIBUTING.md` now caps command length**, and closes `draw.md` to
  further content at 218 lines against 87 for the next largest: a new drawing
  rule has to replace one rather than join it. A command file is loaded whole
  on every invocation, so its length is a cost paid before any output exists.

## 1.45.0 — 2026-08-22

- **Bug fix: the welcome note still said "Eleven commands" and left `:handoff`
  out of the map.** It is the one thing the plugin says on screen, it shows
  once, and it went stale in 1.43.0 when the twelfth command shipped — so
  anyone installing since then got an incomplete list at the only moment they
  were reading one. Fixed in both ports.
- **A test now makes that regression impossible to ship quietly**: every file
  in `commands/` has to appear in its port's welcome text, so a new command
  fails the suite instead of dropping off the map. Verified against the bug it
  was written for — reverting the fix turns it red. The suite goes from 40 to
  42.

## 1.44.0 — 2026-08-22

- **Seven finishing rules for a drawing**, all about how it looks rather than
  what it says: labels in one register (lowercase, unpunctuated, phrased
  alike), one unit style per drawing, arrow length as a spacer and never a
  signal, a cost column that starts at one column and stays there, shortening
  from the head so the identifying tail survives (`…/auth/refresh.rs:88`), and
  a blank line only between stacked blocks — a gap inside one shape reads as
  two.
- **A drawing's fence is now tagged `text`.** Bare broke the ruleset's own
  tag-every-fence rule; a shell tag makes some renderers colour the
  box-drawing characters as syntax and turn the shape into confetti. Every
  example inside the skill and the command is retagged to match.
- Eval case 27 grades the two new checkable ones — the `text` tag and one
  register for labels.

## 1.43.0 — 2026-08-22

- **New command: `/concise:handoff` (PT `/respostas-curtas:passagem`)** — the
  twelfth. It writes the handoff: the branch, the sha, the PR and its state;
  what is done and verified kept apart from what is left with its done
  criterion; the traps only the person leaving can name; what was decided and
  why; and the exact command that resumes the work.
- **It exists because it is the opposite of a status update**, and the two
  were sharing one command's worth of rules. A status update is the delta and
  earns the right to drop what the reader already has. A handoff assumes the
  reader has nothing — no memory of the conversation, no caveat stated three
  messages ago — so **every standing caveat comes back in full** instead of
  being referred to by a clause. The ruleset already said that under "never
  cut"; nothing produced it.
- **The always-on core routes it**, alongside the six commands it already
  named.

## 1.42.0 — 2026-08-22

- **A commit title now carries the area too, completing the family.** A card
  got the rule in 1.32.0 and a PR title in 1.33.0; the commit title — read in
  `git log --oneline`, the narrowest window in the ruleset — kept saying only
  "what changes, in the shape the log uses". Where the repo holds more than
  one area it now comes first, inside whatever shape the log already gives it
  (`fix(invoices):`, a bare `invoices:`, a ticket code). One area, or a log
  with no prefix: nothing is invented.
- **`/concise:pr create` opens the PR, and `/concise:commit run` commits.**
  Both stay draft-only by default; the literal word in the invocation is the
  permission, and nothing else is — not a base ref, not staged changes, not a
  PR you opened earlier in the same conversation. Anything that would make
  the call wrong (no commits over the base, an unfilled hole, `gh` not
  authenticated, an unpushed branch, two unrelated changes staged) stops
  before it and says which, with the draft delivered anyway.
- **The always-on core routes `:draw` and `:status` too.** It named five of
  the eleven commands, so the two that come up most often outside a release
  — showing a shape and reporting where work stands — were never pointed at.

## 1.41.0 — 2026-08-21

- **Bug fix: the ruleset contradicted itself on PR descriptions.** The PR
  section still opened with "the first line says what the PR does" and called
  every template header decoration — three paragraphs before the 1.35.0 rule
  mandating three headed sections that open on what is being solved. The
  opener now says the same thing the rule does, in both ports.
- **Bug fix: three eval cases enforced revoked rules.** Cases 10 and 17
  demanded the pre-1.35.0 PR shape (first line = what the PR does, no header
  above it) and case 11 demanded verb-first card titles — the exact rule
  1.32.0 replaced with "what changes, located". A response following today's
  ruleset failed the suite. All three rubrics now grade the current rules.
- **Three eval cases the rules never had**: a note on a card at three lines
  with the anchor (1.34.0), a PR title with the area first and the state
  after the merge (1.33.0), and a drawing that holds its shape — one glyph
  set, nothing past 72 columns, labels hanging off their box (1.36.0+). The
  suite goes from 24 to 27 cases.
- **Bug fix: the 1.40.0 update-check bypass only worked at the repo root.**
  The detection read `.claude-plugin/marketplace.json` relative to the
  current directory, so a session opened in a subdirectory silently kept the
  daily stamp. The repo root is now resolved through git; a new hook test
  covers the subdirectory, taking the suite to 40.
- **Stale references caught up**: `/concise:rewrite` pointed at the
  "narrow-panel structure limits" — renamed "two widths" with different
  thresholds in 1.32.0 — and both READMEs described `/concise:draw` without
  any of the craft rules from 1.36.0–1.39.0.

## 1.40.0 — 2026-08-21

- **The self-update hook no longer holds the marketplace cache stale for the
  author.** Inside this repo the once-a-day stamp is ignored and the check runs
  every session. Everywhere else it is unchanged: one check a day.
- **What this actually fixes is the update button.** The client compares the
  installed version against the local marketplace clone, not against GitHub, so
  a clone pinned at yesterday's commit greys the button out no matter how many
  releases shipped since. The clone only advances when the marketplace refresh
  runs — which the daily stamp was blocking.
- Two new hook tests cover it: the stamp is ignored inside the marketplace's
  own repo, and still respected in any other directory. The suite is at 39.

## 1.39.0 — 2026-08-21

- **A closed box now has to earn its three lines.** Bare labels on the line are
  the default: `worker ──> cache` is already a drawing, and the same two things
  inside `┌──────┐` frames cost six lines for identical content — the
  fifteen-line budget is only five boxes deep. A closed box is for a node
  holding two lines, or for the block being compared in a before/after, and
  there is one box style per drawing the way there is one glyph set.
- **The happy path stays on the main line and failure drops below it**, with
  the failure arrow carrying what the reader loses — `timeout: order charged,
  not confirmed` — instead of `error`. An inline error route makes the reader
  work out which of the two is normal before the drawing says anything.
- **Repetition is a count, not boxes.** Eight identical consumers are one box
  and `×8`; drawing all eight spends the budget proving they are the same.
- **No legend, no key.** A drawing needing a line to explain a glyph has
  already failed — the meaning folds into the labels or the distinction goes.
  A `×8` or a unit is a label, not a legend.
- **The audit agent checks all four**, alongside the drawing rules it gained in
  1.37.0 and the mermaid conditions from 1.38.0.

## 1.38.0 — 2026-08-21

- **`mermaid` had one clause and no rules; now it has both conditions and seven
  rules.** GitHub renders it, so `/concise:pr` and `/concise:card` reach it
  routinely, and until now nothing said what a good mermaid block looks like.
- **Two conditions, both required, before it is mermaid at all**: the surface
  renders it, *and* the graph is genuinely two-dimensional — a node with two
  arrows in, a cycle, a mesh. A chain stays ASCII, because ASCII survives the
  copy into a terminal, a commit body, or a field that renders nothing.
- **The rules**: `flowchart LR` for a flow and `TD` for a branch, the visible
  label never the node id, every edge labelled, a node shape that means
  something or stays default, no `style`/`classDef`/colour, ten nodes as the
  cap, and a labelling subset that always parses — a block that fails to parse
  renders as an error box, which is worse than no drawing.
- **The audit agent flags a mermaid block on a surface that will not render
  it**, and one used where ASCII would have carried the same chain.

## 1.37.0 — 2026-08-21

- **`/concise:draw` now carries four canonical layouts** — a flow, a branch, a
  before/after, and a call tree — each with a worked skeleton. The command used
  to name four kinds of subject worth drawing and give no shape for any of
  them, so every drawing invented its own layout and two drawings by the same
  author looked unrelated. They are starting points, not moulds: when the real
  shape is none of the four, the real shape wins.
- **A drawing procedure, in order**, because alignment is not fixable
  afterwards: the main line whole first, then the column of each box counted,
  then the labels hung top down with the leftmost closing first, then the
  longest line measured against the seventy-two column limit. The 1.36.0 rules
  said what alignment had to look like and nothing about how to get it.
- **Bug fix: `/concise:audit` contradicted `/concise:pr`.** Item 7 of the audit
  agent still asked a PR description to open with what the PR does — the shape
  1.35.0 replaced with three named sections opening on what is being solved. An
  audited description could fail the rule it had just passed. Fixed in both
  ports.
- **The audit agent now checks drawings at all**: unlabelled arrows, lines past
  seventy-two columns, mixed glyph sets, floating labels, boxes named after
  internals, and a drawing that repeats the sentence above it.

## 1.36.0 — 2026-08-21

- **A drawing now has a column limit, and it is the strict one: seventy-two.**
  The old rule capped lines at fifteen and said nothing about width, so the
  failure it never caught was the one that destroys a drawing outright — a line
  that wraps in the reader's panel, which is not the panel it was drafted in. A
  before/after that will not fit side by side inside that stacks instead of
  shrinking its labels.
- **One glyph set and one direction per drawing.** Box-drawing or plain ASCII,
  the same arrowhead throughout, left to right for a flow and top to bottom for
  a branch, with parallel paths starting at the same column — a ragged left edge
  reads as a difference that is not there.
- **Every label hangs off what it names**, by a `│` down to a `└─`, instead of
  floating between two boxes. The example in the ruleset itself broke this: its
  `2.1 s p95` sat loose between two hops with nothing saying which one it timed.
  It is redrawn.

## 1.35.0 — 2026-08-21

- **A PR description now has three sections, in a fixed order: what is being
  solved, what was done, how to test it.** The order is the change. The old
  rule opened on what the PR does, which the title already said, and left the
  problem as an optional second sentence — so the one thing the reviewer cannot
  reconstruct from the page was the one thing that could be dropped.
- **Markdown is explicitly welcome in a description**: tables, headers on the
  three sections, lists for the deliverables, code spans on paths and values.
  Three sections are three blocks doing different jobs, so they earn their
  headers under the structure rule rather than fighting it. A description that
  reads well is not padding.
- **What counts as padding is named instead of capped**: the description
  competing with the diff — a file-by-file map, a count of what changed, a
  section per area touched. A discarded alternative gets a line, not a section,
  and the argument that discarded it goes to the commit body or the linked
  card.
- `/concise:pr` audits the three sections and their order before delivering.

## 1.34.0 — 2026-08-21


- **A note on a card now has a length, and it is three lines.** The section
  covering comments had rules about shape — claim first, one point, no filler
  praise — and none about length, so a note on an activity came out at the
  length of a chat reply. It is now the summary of the summary: what changed
  since the card was written, or what the reader has to do, with the anchor.
  One line is common.
- **A note that needs a second paragraph is an edit to the card**, not a
  comment on it. A thread is a chronological feed nobody scrolls back through,
  so reasoning parked there is parked where it gets lost; the card body holds
  the standing description and a linked document holds the reasoning.
- **The budget table gained a row for it**, next to the one for a task or an
  issue. `/concise:comment` audits against the three lines before delivering.
  A review comment anchored to a diff line keeps its own shape — this is the
  note on an activity, not the line-level review.

## 1.33.0 — 2026-08-21


- **A PR title now takes the card's title rule, minus the symptom form.** It
  says what changes on merge, in the shape the repo's log already uses, with
  the area first inside that shape when the list holds more than one — the PR
  list cuts the line the same way a board column does. The symptom form does
  not travel: a card names the broken state so someone picks it up, a PR names
  the state after it merges. And a prefix repeating what the list already shows
  beside the title — the repo, a `bug` label, the branch — is spent characters,
  the same as on a card.
- **"Verb first" is gone from the PR title rule**, where it contradicted the
  commit-title rule it claimed to follow: that one has accepted a declarative
  naming the change since 1.0, and only rejects a label with no change in it.
  A repo whose log is declarative no longer gets told to write imperatives.

## 1.32.0 — 2026-08-21


- **A card title now leads with the area, not with a verb.** The old rule
  asked for the action verb and nothing else, which pushed the area to the end
  of the line — and the column cuts the line. "Documents: bold shows up as raw
  asterisks" now passes where it used to fail for having no verb; the verb is
  still right when the symptom alone wouldn't be recognised. A prefix that
  repeats a label the card already carries (`fix(...)` beside a `bugfix` tag)
  is now called out as spent characters.
- **A card body may now carry a table or a header, at a written threshold**:
  a table at three rows by three columns of values, a header past fifteen
  lines with three blocks doing different jobs. The flat ban assumed the body
  was read in the ~300px column; it is read in the detail view a click opens,
  and the column shows only the title. Cards that were split into a linked
  document purely to escape the ban no longer need to be, and `/concise:audit`
  stops reporting those tables as violations.

## 1.31.0 — 2026-08-20


- **The injected core now points at the commands.** Eleven commands shipped
  and nothing told the model to reach for one, so it wrote from what it
  remembered instead of from the diff. The session that cut 1.30.0 is the
  quotable case: the commit message and the PR body for it were written
  without invoking `/concise:commit` or `/concise:pr`, and they only landed in
  the right register because the whole ruleset happened to be open in that
  conversation. In a session that isn't editing this repo, that coincidence
  does not exist.
- **Only the five that leave the conversation are named** — `pr`, `commit`,
  `card`, `comment`, `release`. They are the ones where the command adds a
  fact-gathering step the rules cannot describe: reading the log for the
  title's convention, the diff for what the PR does, the thread before
  replying to it. `plan`, `decide`, `draw`, `status` and `audit` stay out
  because the core is the most contested space in the plugin and their gain is
  register, not grounding.
- **It is a nudge, not a system rule**, and the difference matters: a hook
  denies, a line in the core competes. The deterministic version — extending
  the `PreToolUse` guard to reject a `gh pr create` whose body carries no test
  step, the way it already rejects AI credit — is not in this release, and
  would need the same escape hatches the credit guard ships with.
- The line lands in `hooks/core.md`, `hooks/nucleo.md` and both output styles,
  which `check-parity.sh` holds byte-identical to their cores. Core bullets go
  from ten to eleven in both ports.

## 1.30.0 — 2026-08-20

- **Six commands, closing the gap between what the ruleset governs and what
  you can ask for.** `/concise:release` drafts the changelog entry and the
  release body; `/concise:plan` the plan you are proposing; `/concise:decide`
  a call that is yours, options side by side; `/concise:draw` the ASCII of a
  shape; `/concise:status` the delta-only update; `/concise:audit` runs the
  audit agent from a slash instead of a sentence. PT: `release`, `plano`,
  `decidir`, `desenhar`, `status`, `auditar`.
- **Changelog and release notes get a section of their own.** The rule was one
  sentence at the end of "Commit messages", which is why no command could
  point at it. It now says that what breaks goes first with the migration in
  the same entry, that an internal refactor earns no entry at all, and that
  the file's own shape is the convention the way the log is for a commit
  title.
- **The three that could have been prompts instead read the source first.**
  `/concise:draw` opens the files for every hop and marks the ones it could
  not follow — and refuses outright when the subject doesn't earn a drawing,
  which is the failure a diagram command otherwise ships by default.
  `/concise:status` finds the previous update and the CI run instead of
  recalling them. `/concise:decide` marks a cost it could not verify rather
  than rounding it off.
- **Nothing publishes and nothing executes.** `release` never runs
  `gh release create` and never pushes a tag, `plan` never starts step 1,
  `status` never posts to a channel you named, `audit` never edits the file it
  read. Naming a destination still says where the text would go, not that it
  may go there.
- **The welcome note listed four commands, and there are eleven.**
  `/concise:comment` shipped in 1.29.0 and never reached that string — a
  command nobody is told about is a command nobody runs. It now groups by
  destination instead of spending a clause per command.
- No rule for chat replies changed, so no eval case moved. The commands are
  graded by the sections they follow; the harness measures chat replies, and a
  slash command is not one.

## 1.29.0 — 2026-08-20

- **`/concise:comment` (PT: `/respostas-curtas:comentario`)** drafts the fifth
  destination the ruleset already governs and no command produced: a review
  comment, a reply in a thread, a note on someone's card, or a message to a
  person. The "Comments and replies" section has existed for as long as the
  ruleset has had destinations; until now it only applied when Claude happened
  to be writing one, never when you asked for one.
- The command carries three things the section states and a draft usually
  misses: it **reads the line or the thread before writing** — a comment
  anchored to a `path:line` nobody opened is a guess wearing an anchor — it
  **says whether the comment blocks**, because the reader's first question is
  whether they have to act before merging, and it splits two points into two
  blocks instead of one comment with a list inside.
- **It does not post by default, and a named destination is not permission
  to.** Naming a PR or a card tells the command where the comment would go;
  posting notifies a person, so it waits for you to say so. `/concise:card`
  creates when a destination is named — opening an issue and replying inside
  someone's thread are not the same act.
- No rule changed, so no eval case moved. The command is graded by the section
  it follows; the harness measures chat replies, and a slash command is not
  one.

## 1.28.0 — 2026-08-20

- **The block holding the reader's decision holds the recommendation too.** A
  long delivery ended with two genuinely different ways to verify the work and
  closed on "tell me which one" — the right shape with the advice taken out of
  it, leaving the reader holding a choice whose costs only the writer had
  measured. The rule that gives a decision its own block now says the block
  carries the recommendation with it.
- Case 06 already tested "does not stop at your call", and it holds. What it
  could not see is the same failure at the end of a five-section report, where
  the choice arrives after the writing feels finished. Case 24 is that shape.
- **Case 24 discriminates weakly** — 3 of 3 with the skill in both ports
  against 2 of 3 at baseline — and the map says so. Two cases in a row now sit
  there, and the reason is the same: the failures worth catching happen across
  a long session with tools, and the harness runs one turn without any.
- Writing case 24 turned up a fault in the case rather than in a rule: the
  facts said the second route left "nothing to clean up" while also saying the
  fixture rows were already written. The model followed the contradiction and
  the rubric blamed it.

## 1.27.0 — 2026-08-20

- **The style covers every line the turn puts on the screen, not only the last
  message.** A real delivery opened with nine lines of itinerary — "now the
  schema", "now the docs", "now regenerating the SDK" — sitting above the
  answer. The cut list already banned process narration, but the whole
  document talked about "the response" and "what leaves the conversation",
  so the lines between tool calls read as exempt. They are the ones a reader
  sees first and looks at longest.
- **A table column holding the same value in every row is not a column.** The
  same delivery reported eight met requirements in a grid whose second column
  was eight identical ticks — a sentence's worth of information charging a
  table to read it. Drop the column, or drop the table with it.
- **Bad news goes ahead of the part that is fine.** Eight confirmations
  followed by two defects makes the reader walk past everything that needs
  nothing from them to reach the two things that do. Case 23 only held once
  this was in the completed-work budget as well as in **Never cut** — the
  placement lesson again.
- The path rule from 1.26.0 was holding about half the time in real use, so it
  now also sits on the code-span entry, which is where the decision to
  abbreviate actually happens: the full path costs nothing inside a span.
- Cases 22 and 23 measure it. Case 23 discriminates cleanly — 3 of 3 with the
  skill in both ports against a failure at baseline. **Case 22 barely does:**
  2 of 3 at baseline against 3 of 3 with the skill, and the map says "weakly"
  rather than pretending otherwise. The suite grades the final message, so it
  can only reach the itinerary habit indirectly.

## 1.26.0 — 2026-08-20

- **A path is the whole path the first time it appears.** The name rule from
  1.22.0 was still leaking into paths at about one run in three, shortening
  `web/src/modules/estoque/movimento/movimento-pdf.ts` to the bare filename.
  Saying "a file path is a value" in the cut list was not enough; the rule now
  sits in the exact-values entry, where what counts as the value is decided,
  and says the basename is a different and weaker one. Later mentions may
  still be short.
- **Three green eval checks on every PR were measuring nothing.** Without
  `ANTHROPIC_API_KEY` the job ran its skip branch and reported `pass`, which
  reads as "the rules were checked" on a run that never called the model — a
  green check that proves nothing is worse than no check. A gate job now turns
  the secret into an output, so the eval jobs report `skipped` instead, and
  say why in the run summary.
- The audit agent had not kept up with two rules it can check: a fence tagged
  for the wrong shell or chaining two commands, and a path shortened to its
  basename on first mention.
- **The opt-in `stop-audit` extra was grading responses against a copy of the
  rules, not the rules.** Four lines written by hand inside the script, frozen
  wherever they were when it shipped — an auditor holding last month's
  checklist is worse than none. It reads `hooks/core.md` now, with
  `CONCISE_CORE` for installs where the plugin root is not in the hook's
  environment and the user's own override winning over both. Four tests cover
  the wiring, which had none: the core reaching the prompt, a violation
  becoming a warning, `OK` staying silent, and a missing core falling back
  instead of dying.
- **A name that is the decision stays, and the first full PT run since 1.21.0
  is what found that.** The Portuguese port dropped the route it had called —
  reporting "it calls a different route depending on the type", which leaves
  the reader unable to say which decision was taken, let alone whether it was
  right. The rule already spared the knob you ask someone to turn; it now
  spares the name that *is* the decision you are reporting.
- **Writing a case's own vocabulary into a rule contaminates the case.** The
  first draft of that clause used the route names from case 19. Portuguese
  went to 3 of 3 and English fell to 1 of 3 — the model optimised for that one
  rubric item and compressed the false premise and the gate warnings out of
  the answer. Replaced with a neutral example, both ports hold. Case 19 in
  Portuguese is still the closest to the edge in the suite: one failure in
  nine attempts.
- **The eval harness had grown a ceiling it was about to hit everywhere.** It
  handed the whole skill to the CLI on the command line, which Windows caps at
  32767 characters; the PT skill reached 31 KB and the full PT run died at
  case 17 with "Argument list too long" — the first run of that suite since
  1.21.0. It uses `--append-system-prompt-file` now, so the limit is gone
  rather than postponed, with a warning and the old path for a CLI too old to
  have the flag.
- `CONTRIBUTING.md` told contributors to run the evals and compare, without
  saying that one run per case is not evidence. It now says to use `RUNS=3`,
  and why: the suite read 21/21 for weeks while two cases were failing about
  one run in three.
- `evals/README.md` claimed 18/18 against a suite of 21, and said the
  discriminating power was "those seven" two lines under a sentence counting
  ten.
- **The first full `RUNS=3` sweep is what surfaced both**, and it is the
  headline of this release: all 21 cases now hold three times each, in place
  of a 21/21 line that meant each case drew well once. Cases 10 and 14 looked
  unstable in that sweep and were not — 14 had hit the session limit, and 10
  passed 3 of 3 on re-measurement.

## 1.25.0 — 2026-08-20

- **The commit command still promised a verb-first title**, in its own
  description and in four places across the two READMEs — the rule 1.18.1
  replaced with "the log decides the shape, never the substance". The command
  body had been right since then; the shop window had not, and this repo's own
  log is declarative, so the promise contradicted the product.
- **The marketplace card had fallen behind the plugin's own description** and
  nothing was checking it: the sentence naming what the style governs — chat
  replies, plans, commits, PRs, cards, review comments — reached anyone
  reading `plugin.json` and nobody browsing the marketplace. Fixed, and
  `check-parity.sh` now compares the two, so it cannot drift again quietly.
- The READMEs said the injected core is ~20 lines. It is 36.
- **The fence rule shipped in 1.24.0 had no answer for "platform unknown", and
  case 07 caught it** — the suite scored a `powershell` fence as a violation
  because its rubric hard-coded `bash` while its facts named no platform, so
  the case was really grading the machine the suite happened to run on. Two
  fixes: the rule now defaults to `bash` when neither the hook nor the
  environment says otherwise, because guessing `powershell` at a reader who
  turns out to be on Linux costs more than the reverse; and cases 07 and 17
  state the platform in their facts, the way case 21 already did.
- Running the suite with `RUNS=3` for the first time is what surfaced that.
  Cases 01 through 14 hold three times each; 15 through 21 have not been swept
  yet, and `evals/README.md` says so rather than implying the whole suite has
  been.

## 1.24.0 — 2026-08-20

- **The session hook now says which machine this is, and the fence tag follows
  it.** A command block tagged for the wrong shell does not run: `&&` is a
  parser error in Windows PowerShell 5.1 rather than a warning, and `bash`
  typed there reaches the WSL stub instead of Git Bash. `inject-core.sh`
  detects the platform through `uname` and appends one line naming it —
  `powershell` fences on Windows, `bash` on macOS and Linux, with a note on
  macOS that BSD `sed`, `date` and `readlink` take different flags from GNU.
- The rule sits in the fence bullet too, for the output-style path that has no
  hook: the tag names the shell the reader will paste into, not the one you
  ran the command in, and two steps are two fences rather than a chain.
- `CONCISE_OS=windows|macos|linux` overrides detection, for a Windows machine
  whose terminal is Git Bash or WSL. Seven new hook tests cover the branches,
  including a `hooks.json` with no platform strings, which prints nothing and
  still exits 0.
- Case 21 measures it: 3 of 3 with the skill in both ports, 1 of 3 without.
- The rule→case map said eight discriminating cases where the column had nine.

## 1.23.0 — 2026-08-20

- **A completed-work report stops buying its ≤5 lines by packing.** The budget
  row now says the item count follows the work rather than the number, and
  names the shortcut it was licensing: folding the tail of the list — the
  dependency, the docs, the smaller file — back into a sentence to land on
  five.
- That was the real cause of case 18 being unstable at about 2 of 3 since the
  day it was written, which 1.22.0 recorded as unfixed. The rule it tests was
  never the problem: a dozen claims against a ≤5-line budget left no layout
  that satisfied both, so each run broke somewhere different — four claims in
  one item, then three parentheticals stacked, then prose. Rewording the list
  rule three times only moved the failure. The case now holds 3 of 3 in both
  ports and still fails at baseline.
- **Grouping by file is what forces the packing**, so the list rule says the
  grouping is what gives: one subject with four claims hanging off it is four
  items, or a table with the subject in the first column.
- A drawing is no exemption from the name rule shipped in 1.22.0. A box
  labelled with a table's name teaches nothing; the same box labelled "daily
  copy" is the diagram doing its job.
- Case 18's rubric demanded a list where the skill offers a list *or* a table
  for that content. It accepts either now, and only prose fails — the same
  miscalibration case 10 had.
- **The overloaded-opening test described a failure it could not detect.** It
  asked whether the reader crosses a comma chain before reaching the answer;
  the failure that actually happens is "Yes" followed by three reasons in one
  breath, where the answer comes first and the chain comes after. The test is
  now mechanical: put a full stop after the verdict, and if the sentence was
  still going it was overloaded. The headline rule says it too — the answer
  goes in the first sentence, and nothing else goes in there with it.
- Case 08 was grading punctuation. An em dash after "yes" with the support
  trailing reads the same as a full stop; what the rule protects is the caveat
  getting a sentence of its own. Recalibrated to that, it passes 3 of 3 — and
  3 of 3 at baseline as well, which confirms in measurement what the rule→case
  map already claimed: case 08 documents what Claude Code does by default
  rather than what the plugin adds.

## 1.22.0 — 2026-08-19

- **A name lifted out of the code stays only if you can say what the reader
  does with it.** An investigation came back carrying the job class, the
  table, the repository method and the constant, one per sentence — and the
  person who asked why a total was wrong will open none of them. Replaced by
  the behaviour they stood for, those sentences got shorter and clearer at the
  same time, which is why this cut is worth a pass of its own.
- It lands in three places because it collides with two existing rules.
  **Never cut** now says the exact value is the value, not the name of the
  constant holding it; **Always cut** carries the item; and the final
  checklist has a third step for it. Written once, in the audience section,
  the rule lost every run — the same placement lesson as 1.20.0 and 1.21.0.
- The setting you are asking the reader to approve changing is the exception:
  name it, because approving the change means approving that specific thing.
  Shas, paths, branches, versions and numbers they will check are untouched.
- Case 20 measures it: 3 of 3 with the skill, 0 of 3 without — the cleanest
  discriminator in the suite. Case 19's rubric used to demand the error
  constant in the response; it no longer does.
- Two boundaries were added because the first draft over-cut in measurement: a
  file path stays whole, directory and all, and a library version stays even
  while the name beside it goes. Both were caught by case 18 dropping them.
- **Case 18 is flaky at about 2 of 3, and was before this release** — on its
  own rule, the packed list item. Checked against the 1.21.0 skill to be sure
  this change was not the cause. The rule behind it is not fixed here; the
  finding is recorded in `evals/README.md`.

## 1.21.0 — 2026-08-19

- **What waits on the reader never shares a block with what merely informs
  them.** A delivery report put one open question — an API change only the
  reader can authorise — in the same list as two decisions already made and
  committed, under a heading that joined the jobs with "or": "three things
  to decide or know". The reader had to hunt for the part needing an
  answer. Splitting it is the rule; a heading with "or" in it is the tell.
- The completed-work budget now says it too, which is where the shape of
  the answer is decided — the same placement lesson as 1.20.0.
- Case 19 measures it: 3 of 3 with the skill, 1 of 3 without.

## 1.20.0 — 2026-08-19

- **A list item is an item, not a paragraph with a dash.** One item carries
  one claim, in one line or two; four helpers with a gloss each are four
  items, not one line holding four parentheses. The failure hid in plain
  sight because it looks like a list — the rule the semicolon ban already
  covered in prose, escaping through the format that promised a scan.
- **First baseline run, in an isolated config: 11 of the 18 cases pass with
  no style at all.** Seven measure what the plugin adds; the rest describe
  what Claude Code already does. The suite says 18/18 with the skill, and
  that number was hiding how much of it the skill is responsible for — the
  rule → case map now carries the answer per case.
- Where the rule sits turned out to matter more than how it was worded.
  Stated only as a prohibition, it held in 1 of 3 runs; moved to where a
  list is decided — the definition of what a list is for — it held in 3 of
  3. Case 18 is what measured both.

## 1.19.0 — 2026-08-19

- **A PR description opens with two sentences: what it does, and what was
  wrong without it.** The ruleset asked for the change and never for the
  symptom, so a reviewer got "fixes the fence handling" where they needed
  "the export truncated its own output whenever the description contained a
  code block". Knowing the symptom is what lets someone judge whether the
  fix is the right one. The second sentence goes when the first already
  carries the problem.
- `/concise:pr` takes the problem from the commits, the linked card or the
  branch name — never invented — and the audit agent checks the opening.
- Cases 10 and 17 check it, so the rule regresses instead of drifting.

## 1.18.1 — 2026-08-19

- **The log decides the shape of a title, never its substance.** Adding the
  convention rule created a contradiction with "verb first", and the first
  real eval run found it: this repo's own titles are declarative ("A
  correção entra no núcleo"), so the two rules could not both hold. What a
  title must do — name what changes, inside 72 characters, no AI credit —
  stands; imperative or declarative is the log's call. A bare label
  ("Invoice filter") still fails.
- First real run of the suite, judge and all. It found two things, both
  ours: a miscalibrated rubric (case 10 demanded a deliverables list from a
  single-change PR — the list check moved to case 17) and the title
  contradiction above.

## 1.18.0 — 2026-08-19

Commit messages learn the repo they land in, and two PR fixes from a
real screenshot.

- **The repo's log is the commit convention.** A `fix(scope):` prefix, a
  ticket code, another language — whatever the recent titles do
  consistently, the new message does too, and a commitlint config makes
  the prefix mandatory. `/concise:commit` reads `git log --oneline -15`
  and the commitlint config before writing, and carries the ticket from
  the branch name the way the log does — never invented.
- `/concise:commit` also gives the exact `git restore --staged <paths>`
  when the staged diff is two unrelated changes, and wraps the body near
  72 columns.
- **PR deliverables must be a real markdown list** — `- ` at the start of
  the line. A real PR came out with the changes chained by dashes inside
  one paragraph: the same wall of text the semicolon rule banned, with
  different punctuation.
- **A feature with no screen is not excused from the test step.** The same
  PR said the route was "reachable by direct call" without giving the
  call; the step is the call itself, route and body included.
- Case 16 (commit convention) and case 17 (a PR with five deliverables)
  keep both from regressing.

## 1.17.0 — 2026-08-19

Shorter corrections, from a real reply that ran three times its budget.

- **The correction rule moved into the always-on core.** It was in the full
  ruleset and being skipped, because most turns run on the core alone — so a
  reply that found its own mistake spent a headed section explaining what it
  had misread, which is the account of the error the rule already banned.
- **Re-announcing after a check is now cut explicitly.** Saying the answer,
  going to verify, then opening the next message with the same sentence is a
  shape the ruleset had no name for.
- Case 15 tests both, so the rules regress instead of drifting.

## 1.16.0 — 2026-08-19

Reach: the same rules, in places they could not go before.

- **The core also ships as an output style.** It lives in the system prompt
  instead of being printed by a shell hook — so it works on Windows without
  Git Bash, where the hook fails silently, and it is cached rather than
  re-sent every session. Pick it in `/config` → Output style. The plugin
  does not force it: forcing would override the output style you chose.
  `check-parity` fails if the style and the hook core ever drift apart.
- **A version bump on `main` now tags and publishes a release**, with that
  version's CHANGELOG section as the notes — twelve versions had shipped
  with no tag to pin, roll back to, or watch.
- **The ruleset installs into other agents** — Cursor, Copilot, Codex,
  Windsurf — via `npx skills add`. Only the document travels; the README says
  plainly what stays behind.

## 1.15.0 — 2026-08-19

Measurement that discriminates. No rule changed; what changed is what can
catch a rule breaking.

- **`BASELINE=1` runs the cases with no style at all.** A case that passes
  there measures the model's habits, not the rules — the suite could not tell
  the difference before, and the maintainer's own `CLAUDE.md` was leaking the
  skill into every comparison.
- **`RUNS=3` reports `FLAKY`** instead of letting one lucky attempt read as a
  pass, and `MODEL=` pins the model so two runs are comparable.
- **`CORE=1` judges the always-on core** — the ~20 lines injected into every
  session, the most-used surface of the product, previously untested.
- **Five cases:** PR description, card that stands alone, status delta,
  bad news plus the second question, and draw-the-shape. Nine to fourteen.
- **A rule → case map** in `evals/README.md`, with the gaps named rather than
  implied.
- CI runs the suite for both ports and for the core, and a maintainer can
  launch it by hand on a fork PR, where secrets never reach the job.

## 1.14.0 — 2026-08-19

The surfaces the ruleset didn't reach, and the escape it never had.

- **Plans you propose** get a budget row and a section: the numbered steps
  you will run, the risk named, what it leaves out — and no retelling of the
  exploration that got you there. It is the text a user reads before
  authorising work.
- **Comments and replies** — review comments, issue replies, notes on a card
  — get a section: the claim then the line that proves it, what would change
  your mind instead of a hedged claim, no praise as filler, one point per
  comment. The credit guard now covers `gh pr review` too.
- **Asked to expand, expand.** "Explain in detail" turns the budgets off for
  that turn and the next turn is concise again, unasked — the padding never
  comes back with the length. It is the objection every always-on terse style
  has to answer.
- **Changelog entries** get two lines of rule: what changes for whoever
  installs, not the diff retold.
- Both descriptions now name every surface the ruleset governs, which is what
  the model reads when deciding to load it.

## 1.13.0 — 2026-08-19

Correctness pass over the whole plugin, from an audit of every surface.

- **`/concise:pr` stopped truncating its own output.** The delivery block is
  fenced with four backticks now: a PR description carries a `bash` block by
  rule, and the old three-backtick wrapper ended at that inner fence — on
  nearly every invocation. Same fix in `card` and `rewrite`.
- **The credit guard grew from two commands to eight**, reads the message
  when it comes from a file (`-F`, `--body-file`), and names Copilot, Gemini,
  Cursor and Codex besides Claude. It also gained two escapes, because a
  deterministic guard has false positives: `CONCISE_ALLOW_CREDIT=1` and
  `~/.claude/.concise-no-credit-guard`.
- **The hook logic moved into four versioned scripts** — `credit-guard.sh`,
  `inject-core.sh`, `self-update.sh`, `notices.sh` — byte-identical across
  ports, with the language passed in from `hooks.json`. The guard regex
  existed in four copies that could drift with CI green; now it exists once.
- **Self-update stamps before it runs**, so a permanent failure retries
  tomorrow instead of at every session start forever; takes a lock, so two
  sessions don't update the same clone at once; and announces the version it
  moved to. Opt out with `~/.claude/.concise-no-self-update`.
- **The welcome note is a `systemMessage`** — it reaches the user's screen
  instead of the model's context, which the style itself tells the model to
  cut.
- `/concise:pr` takes extra context besides a base ref, and states it never
  runs `gh pr create`. `/concise:rewrite` reads a file when the argument is a
  path.
- Rules: the `yes/no` opening yields to a false premise or real uncertainty;
  the hook core stopped banning headers the skill allows; two rules that
  failed the repo's own bar were removed. PT gained "antítese" in the
  rhetorical-flourish cut and the sharp reader in its core; EN gained
  "Required" in the description, which is what makes the model reach for the
  skill.
- The audit agent now knows commit messages and the stands-alone test.
- Tooling: `scripts/test-hooks.sh` (26 offline cases, in CI), CI validates
  every plugin JSON, `check-bump` rejects a version that goes backwards,
  `check-parity` compares hook behaviour instead of counting lines, and the
  eval runner aborts on an empty response, a missing rubric or a dead CLI
  instead of scoring them.
- Docs: install says the style starts next session, a quick-start sits at the
  top, uninstall is documented with its state files, the port guide lists
  what a third port must rename, and the stale "six evals" claim is gone.

## 1.12.0 — 2026-08-19

- Status updates carry only the delta: a new budget row and an always-cut
  entry ban re-summarising work an earlier message already reported — "CI
  green, ready to merge" is a whole turn. Both hook cores name it.

## 1.11.0 — 2026-08-19

- The PR description carries the card or issue that motivated the work, as
  a link — `Closes #N` on GitHub, the card's link or id on a board — when
  it exists in the conversation or a tracker tool can find it, and never
  otherwise. `/concise:pr` (`/respostas-curtas:pr`) gained the lookup step.

## 1.10.0 — 2026-08-19

- Self-update checks once per day instead of every session start — a stamp
  in `~/.claude`, written only when the update pair succeeds, so an offline
  day retries next session.
- The first session after install prints a one-line map of the commands
  and the agent, once.
- Repo side, no plugin change: the repo now practises the templates the
  skill preaches (`.github/PULL_REQUEST_TEMPLATE.md` and two issue forms,
  comment-guided so nothing renders as boilerplate), and the eval suite
  grows to nine cases — the `bash` fence, the overloaded opening, and
  commit messages join the six from the examples.

## 1.9.0 — 2026-08-19

- Cards grow three rules: what the conversation settled goes into the
  destination's fields, not the body and not silently the default; the
  tracker's issue template is a contract to fill; and creation starts by
  looking for the card that already exists.
- `/concise:card` (`/respostas-curtas:card`) creating at a destination now
  searches for duplicates first, honours GitHub issue templates, discovers
  and sets fields, links named blockers or parents, and reports what it set
  and what stayed at default.

## 1.8.0 — 2026-08-19

- PR descriptions grow four rules: the repo's `PULL_REQUEST_TEMPLATE` is a
  contract to fill in the register — no boilerplate sections, no checkbox
  ticked that isn't true; a many-file diff says where to start reading; the
  title follows the commit-title rule; and "and also" means two PRs.
- `/concise:pr` (`/respostas-curtas:pr`) reads the branch's commits for the
  why, fills the repo template when one exists, and delivers the title
  ready for `gh pr create --title` alongside the body.

## 1.7.1 — 2026-08-18

- The credit guard also covers the `PowerShell` tool — on Windows, a commit
  made through it used to walk past the 1.7.0 guard.
- The guard now catches compound commands. The 1.7.0 filter matched by
  prefix, so `git add -A && git commit …` — the most common real shape —
  never triggered it; detection moved into the guard itself, which runs as a
  tiny grep on every shell call. Known limit documented: a message passed
  via `git commit -F <file>` stays out of reach.

## 1.7.0 — 2026-08-18

- Credit guard, enabled by default: a `PreToolUse` hook denies `git commit`
  and `gh pr create` whose text carries AI credit — deterministic string
  match, no API call. The ruleset's hardest rule becomes a system rule.
- "Commit messages" section in the skill, and `/concise:commit`
  (`/respostas-curtas:commit`): drafts the message for what is staged —
  verb-first title ≤72 chars, body says why, draft only.
- The `pr` and `card` commands self-audit against their checklists before
  delivering.

## 1.6.0 — 2026-08-18

- Four aesthetic rules for what the model outputs, at zero budget cost: a
  runnable command gets a `bash` fence of its own (and every fence a
  language tag); table cells hold values with the prose staying outside; a
  PR that ships several deliverables lists them one per line instead of
  chaining semicolons; and the overloaded opening joins "Before sending" —
  verdict in sentence one, support from sentence two.
- Both hook cores name the `bash` fence.

## 1.5.1 — 2026-08-18

- Catalogue and manifest descriptions catch up with 1.5.0: three commands and
  the self-update hook, not just `rewrite`.
- Changelog dates corrected to the real merge dates (every release so far
  landed on 2026-08-18).

## 1.5.0 — 2026-08-18

- `/concise:pr` (`/respostas-curtas:pr`): drafts the pull request description
  for the current branch from the real diff, test steps at the end.
- `/concise:card` (`/respostas-curtas:card`): drafts a task/issue card that
  stands alone, and creates it when a reachable destination is named.
- Local core override: `~/.claude/concise-core-override.md`
  (`~/.claude/respostas-curtas-nucleo-override.md`) replaces what the
  `SessionStart` hook injects, and survives auto-updates — editing the cached
  `core.md` no longer does.
- Opt-in Stop auditor in `extras/stop-audit/`: warns when a turn's final
  response clearly violates the core. One API call per turn; off unless you
  install it.
- CI: `check-bump.sh` fails any PR that changes a plugin without bumping its
  version; evals run as an advisory job on PRs that touch `SKILL.md`.
- README: before/after figure, badges, and a full Portuguese translation
  (`README.pt-BR.md`), with structural parity checked in CI.

## 1.4.0 — 2026-08-18

- `/concise:rewrite` (`/respostas-curtas:reescrever`): rewrites a finished
  text to the ruleset without losing information.
- `audit` (`auditar`) agent: returns only the violations — quote, rule,
  one-line fix — plus required content that is missing.
- Self-update: a second `SessionStart` hook updates the plugin in the
  background at each session start (requires a version bump to move).
- CI parity check between the EN and PT ports; eval harness with six judged
  cases in `evals/`.

## 1.3.0 — 2026-08-18

- `SessionStart` hook injects a ~20-line core of the style into every
  session, making the style always-on without depending on invocation.

## 1.2.0 — 2026-08-18

- Tasks and issues: everything a card carries, what enters under condition,
  and the structure a narrow panel holds (no headers, no tables, bold only
  as item labels).

## 1.1.0 — 2026-08-18

- Tasks and issues as a destination surface; the version-bump rule that makes
  `claude plugin update` actually move.

## 1.0.0 — 2026-08-18

- First plugin release: install via marketplace in two commands instead of
  clone and copy.
