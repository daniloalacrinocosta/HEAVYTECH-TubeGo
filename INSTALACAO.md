# Guia de instalação — HEAVYTECH TubeGo 1.1

**Desenvolvido por Danilo | HEAVYTECH**

Este guia é para quem quer **baixar, instalar e usar** o TubeGo em um computador Windows, sem precisar entender de programação.

> **Importante:** instale apenas arquivos deste repositório oficial e leia o instalador antes de executá-lo. O TubeGo executa o PowerShell em segundo plano quando é aberto pelo atalho. Use o aplicativo para baixar apenas conteúdos próprios ou autorizados.

## 1. O que é necessário?

- Computador com Windows 10 ou 11.
- Internet ativa.
- Acesso ao PowerShell e ao `winget` para instalar dependências.
- Ferramentas `yt-dlp` e `FFmpeg`. O `Deno` é recomendado.

## 2. Baixar o instalador do GitHub

1. Abra a página principal deste repositório.
2. Na lista de arquivos, clique em **`Instalar_HEAVYTECH_TubeGo_v1.1.ps1`**.
3. Na tela do arquivo, clique em **Download raw file** (ícone de download à direita da barra acima do código).
4. Salve o arquivo com o nome **`Instalar_HEAVYTECH_TubeGo_v1.1.ps1`** dentro da pasta **Downloads** do Windows.
5. Se o navegador salvar o arquivo com extensão `.txt`, renomeie-o para `.ps1` (ative **Exibir > Extensões de nomes de arquivos** no Explorador).

**Alternativa:** na página principal, clique em **Code > Download ZIP**, extraia o ZIP e localize o mesmo instalador. É preciso extrair o ZIP antes de executar o script.

## 3. Instalar as ferramentas necessárias (uma única vez)

1. Clique no menu **Iniciar**, pesquise **PowerShell** e abra o programa.
2. Cole os três comandos abaixo, um por vez:

```powershell
winget install -e --id yt-dlp.yt-dlp
winget install -e --id yt-dlp.FFmpeg
winget install -e --id DenoLand.Deno
```

3. Se aparecer pedido para aceitar os termos das ferramentas, leia e confirme se estiver de acordo.
4. **Feche e abra o PowerShell** quando as instalações terminarem.
5. Opcionalmente, confirme que tudo está disponível:

```powershell
yt-dlp --version
ffmpeg -version
deno --version
```

Se o Windows disser que `winget` não existe, verifique se o **App Installer** da Microsoft está instalado e atualizado ou peça auxílio ao suporte do computador.

## 4. Instalar o TubeGo (uma única vez)

Com o instalador salvo em **Downloads**, execute no PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\Instalar_HEAVYTECH_TubeGo_v1.1.ps1"
```

Espere a mensagem **`Instalado e verificado com sucesso!`**. O instalador cria um atalho **HEAVYTECH TubeGo** na Área de Trabalho e no menu Iniciar.

Se o instalador estiver em outra pasta, ajuste o caminho no comando.

> O parâmetro `-ExecutionPolicy Bypass` aplica-se somente àquela execução do PowerShell; não altera a configuração global do Windows.

## 5. Abrir e usar

1. Dê dois cliques no ícone **HEAVYTECH TubeGo** na Área de Trabalho.
2. Cole o link de um vídeo que você tem permissão para baixar.
3. Selecione **MP4 720p**, **MP4 1080p** ou **áudio MP3**.
4. Escolha a pasta de destino.
5. Clique em **BAIXAR AGORA**, espere concluir e depois abra a pasta dos arquivos.

A partir daqui **não é necessário abrir o PowerShell manualmente**: o atalho já executa o programa em segundo plano.

## 6. Atualizar

Baixe o instalador da nova versão e execute-o novamente. Esta versão 1.1 pode ser reinstalada por cima da versão 1.0, mantendo o mesmo atalho. Antes de atualizar, feche o TubeGo.

As dependências `yt-dlp` e `FFmpeg` são externas; quando precisarem de atualização, pode-se usar:

```powershell
winget upgrade -e --id yt-dlp.yt-dlp
winget upgrade -e --id yt-dlp.FFmpeg
```

## 7. Resolver problemas comuns

**Clico no ícone e o programa não abre:** execute novamente o instalador 1.1 e verifique se ele mostra `Instalado e verificado com sucesso!`. O aplicativo salva detalhes de falha de inicialização em `%LOCALAPPDATA%\HEAVYTECH\TubeGo\erro-inicializacao.txt` (quando consegue gravar o log).

**O comando `yt-dlp` ou `ffmpeg` não é reconhecido:** feche e abra o PowerShell depois de instalar as dependências. Confirme os comandos da seção 3.

**O vídeo não baixa:** tente um link diferente de conteúdo autorizado e use o botão **Detalhes** para conferir a mensagem. Sites podem alterar suas regras e compatibilidade.

**O instalador não está na pasta Downloads:** localize o arquivo no Explorador e use seu caminho real no comando da seção 4.

## 8. Onde o aplicativo fica instalado?

Os arquivos do aplicativo ficam em:

```text
%LOCALAPPDATA%\HEAVYTECH\TubeGo\
```

Os vídeos são salvos na pasta escolhida dentro do programa, e não fazem parte do instalador ou do GitHub.

## 9. Remover o TubeGo manualmente

Esta versão **não possui desinstalador automático**. Para remover apenas o aplicativo:

1. Feche o TubeGo.
2. Apague o atalho **HEAVYTECH TubeGo** da Área de Trabalho.
3. Apague o atalho do menu Iniciar na pasta **HEAVYTECH**.
4. Exclua a pasta `%LOCALAPPDATA%\HEAVYTECH\TubeGo\`.

Essas ações não removem `yt-dlp`, `FFmpeg` nem `Deno`, pois são programas independentes. Também não apagam os vídeos já baixados.

---

**HEAVYTECH TubeGo 1.1 — Desenvolvido por Danilo**