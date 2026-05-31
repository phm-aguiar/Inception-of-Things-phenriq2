## Diretrizes Gerais da Entrega* Todo o projeto deve ser executado em uma máquina virtual (VM).
* Os arquivos de configuração do seu projeto devem ser colocados na raiz do repositório.
* As pastas correspondentes à parte obrigatória devem ser nomeadas estritamente como: `p1`, `p2` e `p3`.
* Em cada parte, quaisquer scripts necessários devem ser armazenados em uma pasta chamada `scripts`.
* Em cada parte, os arquivos de configuração devem ficar em uma pasta chamada `confs`.
---
# Parte 1: K3s e Vagrant (Pasta `p1`)* Você deve configurar duas máquinas virtuais utilizando o Vagrant.
* O sistema operacional das máquinas deve ser a versão estável mais recente da distribuição escolhida.
* É fortemente aconselhado permitir apenas o mínimo de recursos: 1 CPU e 512 MB (ou 1024 MB) de RAM.
* O nome das máquinas deve ser o login de um dos membros da equipe.
* A primeira máquina (Server) deve ter o hostname terminado em "S" (ex: `loginS`).
* O IP da primeira máquina deve ser `192.168.56.110` na interface de rede primária.
* O K3s deve ser instalado na primeira máquina em modo *controller*.
* A segunda máquina (Server Worker) deve ter o hostname terminado em "SW" (ex: `loginSW`).
* O IP da segunda máquina deve ser `192.168.56.111` na interface de rede primária.
* O K3s deve ser instalado na segunda máquina em modo *agent*.
* Deve ser possível conectar em ambas as máquinas via SSH sem exigir senha.
* A ferramenta `kubectl` também deve ser instalada.
---
## Parte 2: K3s e Três Aplicações Simples (Pasta `p2`)* Apenas uma máquina virtual é necessária para esta parte, usando a versão estável mais recente da distribuição escolhida.
* O K3s deve ser instalado nesta máquina em modo *server*.
* O nome da máquina deve ser o seu login seguido de "S".
* A máquina deve responder no endereço IP `192.168.56.110`.
* Três aplicações web distintas devem ser configuradas para rodar nesta instância do K3s.
* O acesso às aplicações deve depender do HOST utilizado na requisição.
* Requisições com o HOST `app1.com` devem exibir o "app1".
* Requisições com o HOST `app2.com` devem exibir o "app2".
* A aplicação número 2 deve possuir exatamente 3 réplicas configuradas.
* Qualquer outro HOST não especificado deve exibir o "app3" por padrão.
---
## Parte 3: K3d e Argo CD (Pasta `p3`)* O Vagrant não deve ser utilizado nesta etapa.
* O K3d deve ser instalado na máquina virtual, o que exigirá também o Docker.
* Você deve escrever um script para instalar os pacotes e ferramentas necessárias durante a avaliação.
* O cluster deve possuir dois *namespaces*: um dedicado ao Argo CD e outro chamado `dev`.
* O namespace `dev` conterá uma aplicação que será implantada automaticamente pelo Argo CD.
* A fonte de sincronização do Argo CD deve ser um repositório público no GitHub.
* É obrigatório que o nome deste repositório público no GitHub contenha o login de um membro do grupo.
* A aplicação a ser implantada deve possuir duas versões diferentes.
* As versões da aplicação devem estar "tagueadas" como `v1` e `v2`.
* Você pode usar a aplicação fornecida no Docker Hub (`wil42/playground`) ou criar a sua própria e publicá-la em um repositório público do Docker Hub.
* Você deve ser capaz de alterar a versão da aplicação (de v1 para v2) enviando a mudança para o GitHub e verificar se ela foi atualizada automaticamente.