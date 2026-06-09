require 'json'
file = 'class_members.json'
data = JSON.parse(File.read(file))

# Pegar o "dicente" da primeira turma existente (que agora tem os alunos novos que o usuário inseriu)
dicente = data.first['dicente'] || []

classes_info = [
  { code: 'CIC0097', docente: { 'nome' => 'MARISTELA TERTO DE HOLANDA', 'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO', 'formacao' => 'DOUTORADO', 'usuario' => '83807519491', 'email' => 'mholanda@unb.br', 'ocupacao' => 'docente' } },
  { code: 'CIC0105', docente: { 'nome' => 'GENAINA NUNES RODRIGUES', 'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO', 'formacao' => 'DOUTORADO', 'usuario' => 'genaina', 'email' => 'genaina@unb.br', 'ocupacao' => 'docente' } },
  { code: 'CIC0202', docente: { 'nome' => 'EDUARDO ALCHIERI', 'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO', 'formacao' => 'DOUTORADO', 'usuario' => 'alchieri', 'email' => 'alchieri@unb.br', 'ocupacao' => 'docente' } },
  { code: 'CIC0003', docente: { 'nome' => 'MARCUS VINICIUS LAMAR', 'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO', 'formacao' => 'DOUTORADO', 'usuario' => 'lamar', 'email' => 'lamar@unb.br', 'ocupacao' => 'docente' } },
  { code: 'CIC0004', docente: { 'nome' => 'CARLA DENISE CASTANHO', 'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO', 'formacao' => 'DOUTORADO', 'usuario' => 'carla', 'email' => 'carla@unb.br', 'ocupacao' => 'docente' } },
  { code: 'CIC0002', docente: { 'nome' => 'JORGE CARLOS LUCERO', 'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO', 'formacao' => 'DOUTORADO', 'usuario' => 'lucero', 'email' => 'lucero@unb.br', 'ocupacao' => 'docente' } },
  { code: 'CIC0090', docente: { 'nome' => 'MARCOS FAGUNDES CAETANO', 'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO', 'formacao' => 'DOUTORADO', 'usuario' => 'caetano', 'email' => 'caetano@unb.br', 'ocupacao' => 'docente' } },
  { code: 'CIC0229', docente: { 'nome' => 'MARCELO GRANDI MANDELLI', 'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO', 'formacao' => 'DOUTORADO', 'usuario' => 'mandelli', 'email' => 'mandelli@unb.br', 'ocupacao' => 'docente' } },
  { code: 'CIC0197', docente: { 'nome' => 'ROBERTA BARBOSA OLIVEIRA', 'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO', 'formacao' => 'DOUTORADO', 'usuario' => 'roberta', 'email' => 'roberta@unb.br', 'ocupacao' => 'docente' } }
]

new_data = classes_info.map do |info|
  {
    'code' => info[:code],
    'classCode' => 'TA',
    'semester' => '2026.1',
    'dicente' => dicente,
    'docente' => info[:docente]
  }
end

File.write(file, JSON.pretty_generate(new_data))
