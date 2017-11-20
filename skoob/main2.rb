require 'tk'
require 'tkextlib/bwidget'
require './models.rb'

def limpa_telaInicio
	$login.destroy
	$label1.destroy
	$senha.destroy
	$label2.destroy
	$button_login.destroy
end

def clearEditaEditora
	$f5.destroy
end

# CRUD EDITORAS (C - OK; R - OK; U - OK; D - OK)
def limpa_telaInicial_Admin
	$addEditora.destroy
	$listarEditora.destroy
	$editEditora.destroy
	$deleteEditora.destroy
end

def telaInicial_Admin
	# ADICIONAR EDITORA
	$addEditora = TkFrame.new($root) {
	   background '#613687'
	   padx 10
	   pady 10
	   pack('side' => 'left')
	}

	TkLabel.new($addEditora) {
	   text 'Adicionar Editora'
	   pack('fill' => 'x')
	}

	TkLabel.new($addEditora) {
		text 'Nome:'
		pack('fill' => 'x')
	}
	$nome = TkEntry.new($addEditora) {
		pack('fill' => 'x')
	}

	$button_addEditora = TkButton.new($addEditora) {
		pack('fill' => 'x')
		command (proc {adicionar_editora})
		text "Enviar"
	}

	# LISTAR EDITORA
	$listarEditora = TkFrame.new($root) {
	   background '#365784'
	   padx 10
	   pady 10
	   pack('side' => 'right')
	}

	TkLabel.new($listarEditora) {
	   text 'Listar'
	   pack('fill' => 'x')
	}
	$list_editoras = TkListbox.new($listarEditora) do
		width 40
		height 10
		listvariable $lista
		pack('fill' => 'x')
	end

	# EDITAR EDITORA
	$editEditora = TkFrame.new($root) {
		background 'dark slate blue'
		padx 15
		pady 20
		pack('side' => 'right')
	}

	TkLabel.new($editEditora) {
	   text 'Editar'
	   pack('fill' => 'x')
	}
	
	TkLabel.new($editEditora) {
		pack('fill' => 'x')
		text 'Digite o código do editora a ser alterada:'
	} 
	$idEditora = TkEntry.new($editEditora) {
		pack('fill' => 'x')
	}

	$button_editEditora = TkButton.new($editEditora) {
		pack('fill' => 'x')
		command (proc {editaEditora})
		text "Enviar"
	}

	# EXCLUIR EDITORAS
	$deleteEditora = TkFrame.new($root) {
	   background 'dark slate blue'
	   padx 10
	   pady 10
	   pack('side' => 'right')
	}

	TkLabel.new($deleteEditora) {
	   text 'Remover'
	   pack('fill' => 'x')
	}

	TkLabel.new($deleteEditora) {
		pack('fill' => 'x')
		text 'Digite o código da editora a ser excluída:'
	} 
	$editora_id = TkEntry.new($deleteEditora) {
		pack('fill' => 'x')
	}

	$button_deleteEditora = TkButton.new($deleteEditora) {
		pack('fill' => 'x')
		command (proc {excluiEditora})
		text "Enviar"
	}
end

def confereUsuario
	usuarios = Usuario.all

	login = $login.get
	senha = $senha.get
	
	u = Usuario.new
	usuarios.each do |usuario|
		if (usuario.login == 'admin' && usuario.senha == senha)
			u = usuario
			$id_usuario = Usuario.get(usuario.id)

			limpa_telaInicio
			$lista = TkVariable.new(listar_editoras)
			telaInicial_Admin	
		else
			Tk::messageBox :message => 'Login ou senha errados!', :title => 'ERRO'
		end
	end
end

def adicionar_editora 
	editora = Editora.new
	editora.nome = $nome.get
	editora.save
	limpa_telaInicial_Admin
	$lista = TkVariable.new(listar_editoras)
	telaInicial_Admin
end

def listar_editoras
	editoras = Editora.all

	vetEditoras = []
	editoras.each do |editora|
		vetEditoras.push("ID: " + editora.id.to_s + " - Nome: " + editora.nome)
		vetEditoras.push("")
	end
	return vetEditoras
end

def editaEditora
	id = $idEditora.get
		
	if (id == "")
		Tk::messageBox :message => 'Esse campo deve ser preenchido!', :title => 'ERRO'
	else
		editora = Editora.get(id)
		if (editora != nil)
			limpa_telaInicial_Admin
			appendEditaEditora(editora)
		else
			Tk::messageBox :message => 'Digite os índices indicados na lista de editoras!', :title => 'ERRO'
		end
	end
end

def appendEditaEditora(editora)
	$f5 = TkFrame.new($root) {
	   background "lavender"
	   padx 15
	   pady 20
	   pack('side' => 'left')
	}

	TkLabel.new($f5) {
		text 'Nome:'
		pack('fill' => 'x')
	}
	$nomeEditora = TkEntry.new($f5) {
		pack('fill' => 'x')
	}
	$nomeEditora.set(editora.nome)
	
	$edita_editora = TkButton.new($f5) {
		pack('fill' => 'x')
		command (proc {salvaEditaEditora(editora.id)})
		text "Enviar"
	}
end

def salvaEditaEditora(id_editora)
	editora = Editora.get(id_editora)
	editora.update(:nome => $nomeEditora.get)
	clearEditaEditora
	$lista = TkVariable.new(listar_editoras)
	telaInicial_Admin
end

def excluiEditora
	id = $editora_id.get
	 
	if (id == "")
		Tk::messageBox :message => 'Esse campo deve ser preenchido!', :title => 'ERRO'
	else
		begin
			editora = Editora.get(id)
			editora.destroy
			limpa_telaInicial_Admin
			$lista = TkVariable.new(listar_editoras)
			telaInicial_Admin
		rescue
			Tk::messageBox :message => 'Digite os índices indicados na lista de editoras!', :title => 'ERRO'
		end
	end

end





$root = TkRoot.new
$root.title = "Bem-vindo Administrador"
$root.height = 170
$root.width = 400	
$root.background = "#9188C5"

$login = TkEntry.new($root)
$label1 = TkLabel.new($root) do 
	text 'Login:'
end		

$senha = TkEntry.new($root) do
	show '*'
end
$label2 = TkLabel.new($root) do 
	text 'Senha:'
end

$button_login = TkButton.new($root) do
	text "Enviar"
	command (proc {confereUsuario})
end

$login.place('height' => 25, 'width' => 150, 'x' => 150, 'y' => 35)
$label1.place('height' => 25, 'width' => 45, 'x' => 100, 'y' => 35)
$senha.place('height' => 25, 'width' => 150, 'x' => 150, 'y' => 75)
$label2.place('height' => 25, 'width' => 45, 'x' => 100, 'y' => 75)
$button_login.place('height' => 25, 'width' => 45, 'x' => 175, 'y' => 115)

Tk.mainloop