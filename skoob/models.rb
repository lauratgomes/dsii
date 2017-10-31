require 'data_mapper' 
require 'dm-migrations'

DataMapper.setup(:default, 'postgres://postgres:postgres@localhost/skoob')

class Genero
	include DataMapper::Resource
	property :id, Serial
	property :nome, String, :required => true
	has n, :livros, :through => Resource
end

class Editora
	include DataMapper::Resource
	property :id, Serial
	property :nome, String, :required => true
	has n, :livros, :through => Resource
end

class Livro
	include DataMapper::Resource
	property :id, Serial
	property :isbn, String, :required => true
	property :titulo, String, :required => true
	property :autor, String, :required => true
	property :ano_publicacao, Date, :required => true
	property :paginas, Integer
	property :capa, Text
	belongs_to :editora
	belongs_to :genero
	has n, :resenhas, :through => Resource
end

class Resenha
	include DataMapper::Resource
	property :id, Serial
	property :texto, Text, :required => true
	belongs_to :usuario
	belongs_to :livro
end

class Usuario
	include DataMapper::Resource
	property :id, Serial
	property :nome, String, :required => true
	property :login, String, :required => true
	property :senha, String, :required => true
	property :data_nascimento, Date
	property :imagem, Text
	has n, :livros, :through => Resource
	has n, :resenhas, :through => Resource
end

DataMapper.finalize
#DataMapper.auto_migrate!
#DataMapper.auto_upgrade!

# :constraint => :destroy