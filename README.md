# HEAVYTECH TubeGo

**Baixador de vídeos para Windows, com interface gráfica em PowerShell.**

**Desenvolvido por Danilo | HEAVYTECH**

O **TubeGo** permite colar um link, escolher o formato e baixar conteúdo autorizado sem precisar abrir um terminal no uso diário. O programa utiliza [yt-dlp](https://github.com/yt-dlp/yt-dlp) e [FFmpeg](https://ffmpeg.org/) para os downloads e o processamento de mídia.

> **Versão 1.1:** instalada e testada pelo desenvolvedor em dois computadores Windows. As instalações e o funcionamento podem variar de acordo com a máquina, o site e as ferramentas externas.

## Recursos

- Interface desktop em Windows Forms (PowerShell)
- Download de vídeo MP4 até **720p** ou **1080p**, quando as opções estiverem disponíveis na origem
- Extração de áudio **MP3**
- Pasta de destino configurável e botão para abrir a pasta
- Barra de progresso e opção de cancelar
- Janela **Detalhes** para acompanhar a execução
- Atalho na Área de Trabalho e no menu Iniciar
- PowerShell executado automaticamente e oculto pelo atalho
- Configurações locais por usuário

## Requisitos

- Windows 10 ou 11
- Windows PowerShell 5.1 com Windows Forms
- `yt-dlp` e `FFmpeg` disponíveis no sistema
- `Deno` recomendado para compatibilidade com determinados sites
- Acesso à internet para baixar os arquivos

Para instalar as dependências com o **winget**, abra o PowerShell:

```powershell
winget install -e --id yt-dlp.yt-dlp
winget install -e --id yt-dlp.FFmpeg
winget install -e --id DenoLand.Deno
```

Feche e abra o PowerShell após a instalação, se os executáveis não forem encontrados. Verifique com:

```powershell
yt-dlp --version
ffmpeg -version
deno --version
```

> **Para quem vai instalar em outro computador:** veja o [guia passo a passo de instalação](./INSTALACAO.md), que explica como baixar pelo GitHub, instalar, usar, atualizar e remover o aplicativo.

## Instalação do TubeGo (uma única vez)

1. Baixe o arquivo [`Instalar_HEAVYTECH_TubeGo_v1.1.ps1`](./Instalar_HEAVYTECH_TubeGo_v1.1.ps1) e salve em **Downloads**.
2. Se ainda não tiver feito isso, instale as dependências acima.
3. No PowerShell, execute:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\Instalar_HEAVYTECH_TubeGo_v1.1.ps1"
```

4. Aguarde a mensagem `Instalado e verificado com sucesso!`.
5. Depois, abra **HEAVYTECH TubeGo** pelo ícone da Área de Trabalho ou pelo menu Iniciar.

O instalador é autocontido: contém os arquivos do TubeGo compactados no próprio script, instala o aplicativo na pasta do usuário, verifica a inicialização da interface e cria os atalhos. **As ferramentas externas (yt-dlp, FFmpeg e Deno) não vêm incluídas no instalador** e devem ser instaladas separadamente.

O parâmetro `-ExecutionPolicy Bypass` vale para a execução desse processo e **não altera a política global** do computador. Revise o script antes de executá-lo.

## Como usar

1. Abra **HEAVYTECH TubeGo**.
2. Cole o link do vídeo que tem autorização para baixar.
3. Selecione MP4 (720p/1080p) ou áudio MP3.
4. Escolha a pasta onde deseja salvar.
5. Clique em **BAIXAR AGORA** e acompanhe o progresso.

As resoluções e os formatos disponíveis dependem do site e do vídeo. Plataformas podem alterar o funcionamento dos downloads a qualquer momento.

## Estrutura do projeto

```text
HEAVYTECH-TubeGo/
├── Instalar_HEAVYTECH_TubeGo_v1.1.ps1  # instalador autocontido
├── src/
│   ├── TubeGo.ps1                    # interface e lógica
│   ├── Iniciar_TubeGo.ps1            # inicializador e registro de erros
│   └── TubeGo.ico                    # ícone do aplicativo
├── README.md
├── INSTALACAO.md
├── CHANGELOG.md
└── .gitignore
```

### Onde o aplicativo é instalado

```text
%LOCALAPPDATA%\HEAVYTECH\TubeGo\
```

O programa guarda a pasta escolhida e o formato em um arquivo de configuração local. Os vídeos não fazem parte deste repositório.

## Tecnologias

- PowerShell / .NET Windows Forms
- yt-dlp
- FFmpeg
- Deno (quando necessário pelo motor de download)
- Winget (instalação das dependências)

## Uso responsável

Este é um projeto independente, **não afiliado ao YouTube** ou a outras plataformas. Faça download apenas de conteúdos próprios ou quando tiver permissão, de acordo com os direitos autorais e os termos do serviço utilizado. Não fornece formas de contornar DRM ou proteções de acesso.

## Código e distribuição

Projeto publicado para apresentação do portfólio da HEAVYTECH. **Nenhuma licença de reutilização foi concedida neste momento**; a visibilidade pública do código não significa autorização para copiar, modificar ou redistribuir. Consulte o responsável antes de reutilizar.

**Desenvolvido por Danilo | HEAVYTECH**