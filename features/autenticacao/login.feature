# language: pt

Funcionalidade: Sistema de Login
  Como usuário do sistema
  Para que eu possa responder formulários ou gerenciar o sistema
  Eu quero acessar o sistema utilizando um e-mail ou matrícula e uma senha já cadastrada

  Contexto:
    Dado que existe um usuário discente com e-mail "discente@unb.br" e senha "senha123"
    E que existe um usuário docente com e-mail "docente@unb.br" e senha "senha123"
    E que existe um usuário administrador com e-mail "admin@unb.br" e senha "admin123"
    E que estou na página de login

  @cenario_feliz
  Esquema do Cenário: Login bem-sucedido com e-mail
    Quando preencho "E-mail" com "<email>"
    E preencho "Senha" com "<senha>"
    E clico em "Entrar"
    Então devo ser redirecionado para a página inicial
    E devo ver o menu de navegação

    Exemplos:
      | email          | senha    |
      | discente@unb.br | senha123 |
      | docente@unb.br  | senha123 |

  @cenario_feliz
  Cenário: Login bem-sucedido como administrador exibe menu de gerenciamento
    Quando preencho "E-mail" com "admin@unb.br"
    E preencho "Senha" com "admin123"
    E clico em "Entrar"
    Então devo ser redirecionado para a página inicial
    E devo ver o menu de navegação
    E devo ver a opção de gerenciamento no menu lateral

  @cenario_feliz
  Cenário: Login bem-sucedido com matrícula
    Dado que existe um usuário com matrícula "232007830" e senha "senha123"
    Quando preencho "Matrícula" com "232007830"
    E preencho "Senha" com "senha123"
    E clico em "Entrar"
    Então devo ser redirecionado para a página inicial

  @cenario_triste
  Cenário: Login com senha incorreta
    Quando preencho "E-mail" com "discente@unb.br"
    E preencho "Senha" com "senhaerrada"
    E clico em "Entrar"
    Então devo permanecer na página de login
    E devo ver a mensagem "E-mail ou senha inválidos"

  @cenario_triste
  Cenário: Login com e-mail não cadastrado
    Quando preencho "E-mail" com "naoexiste@unb.br"
    E preencho "Senha" com "qualquer123"
    E clico em "Entrar"
    Então devo permanecer na página de login
    E devo ver a mensagem "E-mail ou senha inválidos"

  @cenario_triste
  Cenário: Login com e-mail em formato inválido
    Quando preencho "E-mail" com "emailsemarroba"
    E preencho "Senha" com "senha123"
    E clico em "Entrar"
    Então devo permanecer na página de login
    E devo ver a mensagem "E-mail inválido"

  @cenario_triste
  Cenário: Login com campo de e-mail vazio
    Quando preencho "Senha" com "senha123"
    E clico em "Entrar"
    Então devo permanecer na página de login
    E devo ver a mensagem "Preencha todos os campos obrigatórios"

  @cenario_triste
  Cenário: Login com campo de senha vazio
    Quando preencho "E-mail" com "discente@unb.br"
    E clico em "Entrar"
    Então devo permanecer na página de login
    E devo ver a mensagem "Preencha todos os campos obrigatórios"

  @cenario_triste
  Cenário: Login com todos os campos vazios
    Quando clico em "Entrar" sem preencher nenhum campo
    Então devo permanecer na página de login
    E devo ver a mensagem "Preencha todos os campos obrigatórios"

  @cenario_triste
  Cenário: Login com usuário inativo
    Dado que existe um usuário inativo com e-mail "inativo@unb.br" e senha "senha123"
    Quando preencho "E-mail" com "inativo@unb.br"
    E preencho "Senha" com "senha123"
    E clico em "Entrar"
    Então devo permanecer na página de login
    E devo ver a mensagem "Usuário inativo. Entre em contato com o administrador"

  @cenario_triste
  Cenário: Login com senha sem caracteres suficientes
    Quando preencho "E-mail" com "discente@unb.br"
    E preencho "Senha" com "123"
    E clico em "Entrar"
    Então devo permanecer na página de login
    E devo ver a mensagem "E-mail ou senha inválidos"
