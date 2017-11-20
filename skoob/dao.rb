require 'pg'
require './models.rb'

class DAO
	def initialize
		@con = PG.connect :dbname => 'skoob',
        						  :user => 'postgres',
        						  :host => 'localhost'
	end


  def autenticacao(login, senha) 
    rs = @con.exec("SELECT * FROM usuarios WHERE login = $1", [login])
    flag = false
    rs.each do |user|
      usuario = Usuario.new
      usuario.id = user['id'].to_i
      usuario.login = user['login'].to_s
      usuario.senha = user['senha'].to_s

      if (usuario.login == login && usuario.senha == senha)
        return usuario
      end
    end
    flag
  end


  def resenhas_usuario(id_usuario)
    resenhas = []
    rs = @con.exec("SELECT * FROM resenhas WHERE usuario_id = $1 ORDER BY id", [id_usuario])
    rs.each do |resenha_user|
      resenha = Resenha.new
      resenha.id = resenha_user['id'].to_i
      resenha.texto = resenha_user['texto'].to_s
      resenha.livro_id = resenha_user['livro_id'].to_i
      resenhas.push(resenha)
    end

    return resenhas
  end


  def resenhas_livro(livro)
    resenhas = []
    rs = @con.exec("SELECT * FROM resenhas WHERE livro_id = $1", [livro])
    rs.each do |resenha_livro|
      resenha = Resenha.new
     
      resenha.id = resenha_livro['id'].to_i
      resenha.texto = resenha_livro['texto'].to_s
      resenha.usuario_id = Usuario.get(resenha_livro['usuario_id'].to_i)
      resenha.livro_id = Livro.get(resenha_livro['livro_id'].to_i)
      resenhas.push(resenha)
    end

    return resenhas
  end

  def resenhasAll
    resenhas = []
    rs = @con.exec("SELECT * FROM resenhas")
    rs.each do |resenha|
      resenha2 = Resenha.new
     
      resenha2.id = resenha['id'].to_i
      resenha2.texto = resenha['texto'].to_s
      resenha2.usuario_id = Usuario.get(resenha['usuario_id'].to_i)
      resenha2.livro_id = Livro.get(resenha['livro_id'].to_i)
      resenhas.push(resenha2)
    end

    return resenhas
  end

  def retornaId_resenha
    rs = @con.exec("SELECT id FROM resenhas ORDER BY id DESC LIMIT 1")
    rs.each do |resenha|
      id = resenha['id'].to_i
      return id
    end
  end


  def retornaId_usuario
    rs = @con.exec("SELECT id FROM usuarios ORDER BY id DESC LIMIT 1")
    rs.each do |usuario|
      id = usuario['id'].to_i
      return id
    end
  end


  def retornaId_livro
    rs = @con.exec("SELECT id FROM livros ORDER BY id DESC LIMIT 1")
    rs.each do |livro|
      id = livro['id'].to_s
      return id
    end
  end


  
end