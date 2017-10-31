require 'sinatra'
require 'erb'
require './dao.rb'
require './models.rb'

enable :sessions

dao = DAO.new

get '/' do
	erb :index
end

post '/login' do
	login = params['login'].to_s
	senha = params['senha'].to_s

	retorno = dao.autenticacao(login, senha)
	if (retorno != false)
		session[:id] = retorno.id	
		session[:login] = retorno.login
		session[:senha] = retorno.senha
		redirect '/administrador/'
	else
		redirect '/administrador/*'
	end
end

get '/logout' do
	session.clear
	erb :index
end

get '/administrador/' do
	@usuario = Usuario.get(session['id'].to_i)
	erb :perfil, :layout => :layout_logout
end

before '/administrador/*' do
	puts session[:login].nil?
	puts session[:senha].nil?

	if (session[:login].nil? && session[:senha].nil?)
		halt 404, 'Esta página é apenas para pessoas autorizadas. Sinto muito.'
	end
end



# CRUD GENERO (C - OK; R - OK; U - OK; D - OK)
get '/administrador/tela_adicionar_genero' do
	erb :tela_adicionar_genero, :layout => :layout_logout
end

post '/administrador/adicionar_genero' do
	genero = Genero.new
	genero.nome = params['nome'].to_s
	genero.save
	redirect "/administrador/listar_genero"
end

get '/administrador/listar_genero' do
	@vetGenero = Genero.all
	erb :listar_genero, :layout => :layout_logout
end

get '/administrador/tela_alterar_genero/:id' do
	@genero = Genero.get(params['id'].to_i)
	erb :tela_alterar_genero, :layout => :layout_logout
end

post '/administrador/alterar_genero' do
	genero = Genero.get(params['id'].to_i)
	genero.update(:nome => params[:nome])
	redirect "/administrador/listar_genero"
end

get '/administrador/excluir_genero/:id' do
	genero = Genero.get(params['id'].to_i)
	genero.update(:livros => [])
	genero.destroy
	redirect "/administrador/listar_genero"
end








# CRUD EDITORA (C - OK; R - OK; U - OK; D - OK)
get '/administrador/tela_adicionar_editora' do
	erb :tela_adicionar_editora, :layout => :layout_logout
end

post '/administrador/adicionar_editora' do
	editora = Editora.new
	editora.nome = params['nome']
	editora.save
	redirect "/administrador/listar_editora"
end

get '/administrador/listar_editora' do
	@vetEditora = Editora.all
	erb :listar_editora, :layout => :layout_logout
end

get '/administrador/tela_alterar_editora/:id' do
	@editora = Editora.get(params['id'].to_i)
	erb :tela_alterar_editora, :layout => :layout_logout
end

post '/administrador/alterar_editora' do
	editora = Editora.get(params['id'].to_i)
	editora.update(:nome => params[:nome])
	redirect "/administrador/listar_editora"
end

get '/administrador/excluir_editora/:id' do
	adapter = DataMapper.repository(:default).adapter
	adapter.execute("DELETE FROM editora_livros WHERE editora_id = ?", params['id'].to_i)
	adapter.execute("DELETE FROM genero_livros WHERE livro_id in (SELECT id FROM livros WHERE editora_id = ?)", params['id'].to_i)	 
	adapter.execute("DELETE FROM resenhas WHERE livro_id in (SELECT id FROM livros WHERE editora_id = ?)", params['id'].to_i)	 
	adapter.execute("DELETE FROM livros WHERE editora_id = ?", params['id'].to_i)
	editora = Editora.get(params['id'].to_i)
	editora.destroy
	redirect "/administrador/listar_editora"
end








# CRUD USUARIO (C - OK; R - OK; U - OK; D - OK)
get '/administrador/tela_adicionar_usuario' do
	erb :tela_adicionar_usuario, :layout => :layout_logout
end

post '/administrador/adicionar_usuario' do
	usuario = Usuario.new
	usuario.nome = params[:nome].to_s
	usuario.login = params[:login].to_s
	usuario.senha = params[:senha].to_s
	usuario.data_nascimento = params[:data_nascimento]

	if (params[:imagem] != nil)
		imagem = params[:imagem][:tempfile]
		extensao = File.extname(imagem)

		if (usuario.save)
			File.open('./public/uploads/usuarios/' + usuario.id.to_s + extensao, "wb") do |f|
				f.write(params[:imagem][:tempfile].read)
				usuario_imagem = usuario.id.to_s + extensao
				usuario.update(:imagem => usuario_imagem)
			end
		end
	else 
		usuario.save
	end

	redirect "/administrador/listar_usuario"
end

get '/administrador/listar_usuario' do
	@vetUsuario = Usuario.all
	erb :listar_usuario, :layout => :layout_logout
end

get '/administrador/tela_alterar_usuario/:id' do
	@usuario = Usuario.get(params['id'].to_i)
	erb :tela_alterar_usuario, :layout => :layout_logout
end

post '/administrador/alterar_usuario' do
	usuario = Usuario.get(params['id'].to_i)
	usuario.update(:nome => params[:nome], :senha => params[:senha], :data_nascimento => params[:data_nascimento])
	
	if (params[:imagem] != nil)
		imagem = params[:imagem][:tempfile]
		extensao = File.extname(imagem)

		if (usuario.imagem != nil)
			begin
				File.delete("./public/uploads/usuarios/#{usuario.imagem}")
			rescue
				puts "oi"
			end			
		end

		File.open('./public/uploads/usuarios/' + usuario.id.to_s + extensao, "wb") do |f|
			f.write(params[:imagem][:tempfile].read)
			usuario_imagem = usuario.id.to_s + extensao
			usuario.update(:imagem => usuario_imagem)
		end
	end

	redirect "/administrador/listar_usuario"
end

get '/administrador/excluir_usuario/:id' do
	usuario = Usuario.get(params['id'].to_i)

	usuario.update(:livros => [], :resenhas => [])

	if (usuario.imagem != nil)
		begin
			File.delete("./public/uploads/usuarios/#{usuario.imagem}")
		rescue
			puts "oi"
		end			
	end
	usuario.destroy
	redirect "/administrador/listar_usuario"
end

get '/administrador/adicionar_estante/:usuario/:id_livro' do
	usuario = Usuario.get(params[:usuario].to_i)
	livro = Livro.get(params[:id_livro].to_i)
	usuario.livros << livro
	usuario.save

	redirect "/administrador/perfil/#{usuario.id}"
end

get '/administrador/excluir_estante/:usuario/:id_livro' do
	usuario = Usuario.get(params[:usuario].to_i)
	livro = Livro.get(params[:id_livro].to_i)

	vetLivros = usuario.livros
	vetLivrosAux = []

	vetLivrosAux.each do |livro_usuario|
		if (livro_usuario.livro_id != livro.id)
			vetLivrosAux.push(livro_usuario)
		end
	end
	usuario.update(:livros => vetLivrosAux)
	redirect "/administrador/perfil/#{usuario.id}"
end









# CRUD LIVRO (C - OK; R - OK; U - OK; D - OK)
get '/administrador/tela_adicionar_livro' do
	@vetEditora = Editora.all
	@vetGenero = Genero.all
	erb :tela_adicionar_livro, :layout => :layout_logout
end

post '/administrador/adicionar_livro' do
	livro = Livro.new
	livro.isbn = params[:isbn].to_s
	livro.titulo = params[:titulo].to_s
	livro.autor = params[:autor].to_s
	livro.ano_publicacao = params[:ano_publicacao]
	livro.paginas = params[:paginas]

	editora = Editora.get(params[:editora].to_i)
	livro.editora = editora

	genero = Genero.get(params[:genero].to_i)
	livro.genero = genero
	
	if (params[:capa] != nil)
		capa = params[:capa][:tempfile]
		extensao = File.extname(capa)

		if (livro.save)
			File.open('./public/uploads/livros/' + livro.id.to_s + extensao, "wb") do |f|
				f.write(params[:capa][:tempfile].read)
				livro_capa = livro.id.to_s + extensao
				livro.update(:capa => livro_capa)
			end
		end
	else
		livro.save
	end

	editora.livros << Livro.get(livro.id)
	editora.save 

	genero.livros << Livro.get(livro.id)
	genero.save

	redirect "/administrador/listar_livro"
end

get '/administrador/listar_livro' do
	@vetLivro = Livro.all
	erb :listar_livro, :layout => :layout_logout
end

get '/administrador/tela_alterar_livro/:id' do
	@vetEditora = Editora.all
	@vetGenero = Genero.all
	@livro = Livro.get(params['id'].to_i)
	erb :tela_alterar_livro, :layout => :layout_logout
end

post '/administrador/alterar_livro' do
	livro = Livro.get(params['id'].to_i)
	livro.update(:titulo => params[:titulo], :autor => params[:autor], :ano_publicacao => params[:ano_publicacao], :paginas => params[:paginas], :editora => Editora.get(params[:editora].to_i), :genero => Genero.get(params[:genero].to_i))
	
	if (params[:capa] != nil)
		capa = params[:capa][:tempfile]
		extensao = File.extname(capa)

		if (livro.capa != nil)
			File.delete("./public/uploads/livros/#{livro.capa}")
		end
		
		File.open('./public/uploads/livros/' + livro.id.to_s + extensao, "wb") do |f|
			f.write(params[:capa][:tempfile].read)
			livro_capa = livro.id.to_s + extensao
			livro.update(:capa => livro_capa)
		end
	end

	redirect "/administrador/listar_livro"
end

get '/administrador/excluir_livro/:id' do
	livro = Livro.get(params['id'].to_i)
	livro.update(:resenhas => [])

	if (livro.capa != nil)
		File.delete("./public/uploads/livros/#{livro.capa}")
	end

	genero = livro.genero
	editora = livro.editora

	vetLivros = genero.livros
	vetLivrosAux = []

	vetLivrosAux.each do |livro_genero|
		if (livro_genero.livro_id != livro.id)
			vetLivrosAux.push(livro_genero)
		end
	end
	genero.update(:livros => vetLivrosAux)

	vetLivros = editora.livros
	vetLivrosAux = []

	vetLivrosAux.each do |livro_editora|
		if (livro_editora.livro_id != livro.id)
			vetLivrosAux.push(livro_editora)
		end
	end
	editora.update(:livros => vetLivrosAux)

	adapter = DataMapper.repository(:default).adapter
	adapter.execute("DELETE FROM livro_usuarios WHERE livro_id = ?", livro.id)
	livro.destroy
	redirect "/administrador/listar_livro"
end











# CRUD RESENHA (C - OK; R - OK; U - OK; D - OK)
get '/administrador/tela_adicionar_resenha/:usuario/:livro' do
	@usuario = params['usuario'].to_i
	@livro = params['livro'].to_i
	erb :tela_adicionar_resenha, :layout => :layout_logout
end

post '/administrador/adicionar_resenha' do
	usuario = Usuario.get(params['usuario'].to_i)
	livro = Livro.get(params['livro'].to_i)

	resenha = Resenha.new
	resenha.texto = params[:texto]
	resenha.usuario_id = usuario.id
	resenha.livro_id = livro.id

	if (resenha.save)
		id_resenha = dao.retornaId_resenha()

		usuario.resenhas << Resenha.get(id_resenha)
		usuario.save

		livro.resenhas << Resenha.get(id_resenha)
		livro.save
	end

	redirect "/administrador/resenha_livro/#{livro.id}"
end


get '/administrador/listar_resenha' do
	@vetResenha = Resenha.all
	erb :listar_resenha, :layout => :layout_logout
end

post '/administrador/alterar_resenha' do
	resenha = Resenha.get(params['id'].to_i)
	resenha.update(:texto => params[:texto])
	redirect "/administrador/resenha_livro/#{resenha.livro_id}"
end

get '/administrador/excluir_resenha/:usuario/:livro/:id_resenha' do
	usuario = Usuario.get(params['usuario'].to_i)
	livro = Livro.get(params['livro'].to_i)
	resenha = Resenha.get(params['id_resenha'].to_i)

	vetResenha = livro.resenhas
	vetResenhaAux = []
	vetResenha.each do |usuario_resenha|
		if (usuario_resenha.id != resenha.id)
			vetResenhaAux.push(usuario_resenha)
		end
	end
	livro.update(:resenhas => vetResenhaAux)

	vetResenha = usuario.resenhas
	vetResenhaAux = []
	vetResenha.each do |usuario_resenha|
		if (usuario_resenha.id != resenha.id)
			vetResenhaAux.push(usuario_resenha)
		end
	end	
	usuario.update(:resenhas => vetResenhaAux)

	resenha.destroy
	redirect "/administrador/listar_resenha"
end

get '/administrador/como_fazer_resenha' do
	erb :como_fazer_resenha, :layout => :layout_logout
end

get '/administrador/tela_alterar_resenha/:id' do
	@resenha = Resenha.get(params['id'].to_i)
	erb :tela_alterar_resenha, :layout => :layout_logout
end

get '/administrador/resenha_livro/:id_livro' do
	livro = Livro.get(params['id_livro'].to_i)
	@vetResenha = dao.resenhas_livro(livro.id)
	
	erb :listar_resenha, :layout => :layout_logout
end

get '/administrador/perfil/:id_usuario' do
	@usuario = Usuario.get(params['id_usuario'].to_i)
	erb :perfil, :layout => :layout_logout
end







get '/administrador/buscar_livro/:livro' do
	@vetLivro = []
	livro = params['livro'].to_s

	livros = repository(:default).adapter.select("SELECT *
												  FROM livros
												  WHERE titulo ILIKE '%{livro}%'
												  ORDER BY id")
	livros.each do |livro|
		@vetLivro.push(livro)
	end
	erb :listar_livro
end

get '/administrador/buscar_genero/:genero' do
	@vetGenero = []
	genero = params['genero']
	puts "????????????????????"
	puts genero
	
	generos = repository(:default).adapter.select("SELECT *
												  FROM generos
												  WHERE nome ILIKE '%{genero}%'
												  ORDER BY id")
	generos.each do |genero|
		@vetGenero.push(genero)
	end
	erb :listar_genero
end

get '/administrador/buscar_editora/:editora' do
	@vetEditora = []
	editora = params['editora'].to_s

	editora = repository(:default).adapter.select("SELECT *
												  FROM editoras
												  WHERE nome ILIKE '%{editora}%'
												  ORDER BY id")
	editoras.each do |editora|
		@vetEditora.push(editora)
	end
	erb :listar_editora
end

get '/administrador/buscar_usuario/:usuario' do
	@vetUsuario = []
	usuario = params['usuario'].to_s

	usuarios = repository(:default).adapter.select("SELECT *
												  FROM usuarios
												  WHERE login ILIKE '%{usuario}%'
												  ORDER BY id")
	usuarios.each do |usuario|
		@vetUsuario.push(usuario)
	end
	erb :listar_usuario
end

get '/administrador/buscar_resenha/:resenha' do
	@vetResenha = []
	resenha = params['resenha'].to_s

	resenhas = repository(:default).adapter.select("SELECT *
												  FROM resenhas
												  WHERE texto ILIKE '%{resenha}%'
												  ORDER BY id")
	resenhas.each do |resenha|
		@vetResenha.push(resenha)
	end
	erb :listar_resenha
end