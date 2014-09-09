Gem::Specification.new do |s|
 s.name = 'snake'
 s.version = '0.0.3'
 s.executables << 'snake'
 s.date = '2014-09-09'
 s.summary = 'Snake Game'
 s.description = 'A simple snake game powered by Gosu framework'
 s.authors = ['Robison Santos']
 s.email = ''
 s.files = ['lib/consts.rb', 
            'lib/fruit.rb', 
            'lib/snake.rb', 
            'lib/snake_game.rb', 
            'media/chery.png',
            'media/double_fruit.png',
            'media/fruit.png',
            'media/half_fruit.png',
            'media/head.png',
            'media/smb_1-up.wav',
            'media/smb_coin.wav',
            'media/smb_mariodie.wav',
            'media/smb_pipe.wav',
            'media/smb_vine.wav',
            'media/snake.png',
            'media/space.png']
 s.add_runtime_dependency 'gosu', '0.7.50'
 s.homepage = ''
 s.license = 'MIT'
end
