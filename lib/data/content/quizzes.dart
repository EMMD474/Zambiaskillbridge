import '../../models/models.dart';

/// Original demonstration questions written for SkillBridge.
/// They are NOT official TEVETA examination questions.
const kQuizzes = <Quiz>[
  Quiz(
    'electrical_safety',
    'electrical',
    'Electrical safety',
    'Basic safety habits for anyone who works near electrical installations.',
    'electrical_safety',
    [
      QuizQuestion(
        'What should you do first before working on a circuit?',
        [
          'Switch off and isolate the supply, then confirm it is dead',
          'Wear rubber slippers and carry on',
          'Touch the wire quickly to see if it is live',
          'Ask someone to hold the cable for you',
        ],
        0,
        'Always isolate the supply and prove it is dead with a suitable tester before touching conductors. Rubber slippers are not reliable protection.',
      ),
      QuizQuestion(
        'A person is stuck to a live appliance after an electric shock. What is the safest first action?',
        [
          'Pull them away with your bare hands',
          'Switch off the power at the source if you can do so safely, then call for help',
          'Pour water on the appliance',
          'Wait for it to stop by itself',
        ],
        1,
        'Cut the power first. Touching the person while the current is flowing can make you a second victim.',
      ),
      QuizQuestion(
        'Why should a breaker or fuse match the rating of the cable it protects?',
        [
          'So the bill is lower',
          'So the cable can carry any load',
          'So the protection trips before the cable overheats',
          'It makes no difference',
        ],
        2,
        'A protective device that is too large will not trip when the cable is overloaded, which can cause fires.',
      ),
      QuizQuestion(
        'What is the main purpose of the earth connection?',
        [
          'To make appliances run faster',
          'To give fault current a safe path so the protective device trips',
          'To store electricity',
          'To reduce the colour of the wire',
        ],
        1,
        'An earth connection lets fault current flow safely, so a fault is cleared quickly instead of leaving metal parts live.',
      ),
      QuizQuestion(
        'An extension cable has exposed copper. Is it safe to cover it with tape and keep using it?',
        [
          'Yes, tape is enough',
          'Yes, if it is only used outdoors',
          'No, damaged cable should be replaced or properly repaired by a competent person',
          'Yes, if the load is small',
        ],
        2,
        'Tape is not a safe repair for damaged insulation. Damaged cable should be taken out of use.',
      ),
    ],
  ),
  Quiz(
    'plumbing_basics',
    'plumbing',
    'Plumbing basics',
    'Core ideas every plumber uses on small domestic jobs.',
    'plumbing_basics',
    [
      QuizQuestion(
        'What is thread seal (PTFE) tape mainly used for?',
        [
          'Cutting pipes',
          'Sealing threaded pipe joints',
          'Cleaning drains',
          'Measuring water pressure',
        ],
        1,
        'Wrapped around male threads, PTFE tape helps seal threaded fittings against leaks.',
      ),
      QuizQuestion(
        'What should you do before replacing the washer in a dripping tap?',
        [
          'Turn off the water supply to that tap',
          'Heat the pipe',
          'Remove the whole sink',
          'Open every tap in the house',
        ],
        0,
        'Isolating the water first prevents flooding and makes the repair safe and tidy.',
      ),
      QuizQuestion(
        'What is the main job of a P-trap or U-bend under a sink?',
        [
          'It speeds up the water',
          'It holds a small amount of water that blocks drain gases',
          'It filters the water',
          'It heats the water',
        ],
        1,
        'The water held in the bend forms a seal that stops bad smells and gases coming back up.',
      ),
      QuizQuestion(
        'A tap keeps dripping even when fully closed. What is the most likely cause?',
        [
          'A worn washer or seal',
          'A broken water meter',
          'Too many people in the house',
          'The pipe is too long',
        ],
        0,
        'Worn washers and seals are the usual cause of a constant drip from a closed tap.',
      ),
      QuizQuestion(
        'Why should the end of a cut pipe be deburred?',
        [
          'To make the pipe look shiny',
          'To make the pipe longer',
          'To remove rough edges that can restrict flow or damage seals',
          'It is not necessary',
        ],
        2,
        'Burrs can cut seals, catch debris and slow the flow. Smooth the edge before fitting.',
      ),
    ],
  ),
  Quiz(
    'welding_safety',
    'welding',
    'Welding safety',
    'Protecting yourself and others while cutting and welding.',
    'welding_safety',
    [
      QuizQuestion(
        'Why must you use a proper welding helmet with the correct shade?',
        [
          'It keeps the hair tidy',
          'It protects your eyes and face from arc radiation and sparks',
          'It makes the weld stronger',
          'It is only needed for thick metal',
        ],
        1,
        'Arc light can burn the eyes and skin. Use the right shade and never look at the arc without protection.',
      ),
      QuizQuestion(
        'What should you do about flammable materials near a welding job?',
        [
          'Ignore them if they are far enough',
          'Cover them with plastic sheeting',
          'Remove them or shield them, and keep a suitable extinguisher close',
          'Spray them with fuel to make them wet',
        ],
        2,
        'Sparks can travel a long way. Clear the area or protect it, and keep fire-fighting equipment ready.',
      ),
      QuizQuestion(
        'Why is ventilation important when welding galvanised or coated steel?',
        [
          'Fumes can harm your health',
          'It cools the electrode',
          'It makes the arc brighter',
          'It is only needed outdoors',
        ],
        0,
        'Welding coated metals can release harmful fumes. Use fresh air movement or fume extraction.',
      ),
      QuizQuestion(
        'A drum once held fuel. What is the safe approach before welding on it?',
        [
          'Weld quickly before gas builds up',
          'Do not weld until it has been properly cleaned and made safe by a competent person',
          'Light a match to test it',
          'Fill it with air',
        ],
        1,
        'Residual vapour can explode. Never weld on containers that held flammable liquids unless they are made safe.',
      ),
      QuizQuestion(
        'Which clothing is the best choice for welding?',
        [
          'Synthetic shorts and sandals',
          'Light nylon jacket',
          'Flame-resistant overalls, leather gloves and closed leather boots',
          'Wet cotton shirt',
        ],
        2,
        'Synthetic fabric can melt onto skin. Use flame-resistant clothing and cover all skin.',
      ),
    ],
  ),
  Quiz(
    'carpentry_measurements',
    'carpentry',
    'Carpentry measurements',
    'Measuring, marking and cutting accurately.',
    'carpentry_foundations',
    [
      QuizQuestion(
        'A board needs to be 1.2 metres long. How many millimetres is that?',
        ['12 mm', '120 mm', '1 200 mm', '12 000 mm'],
        2,
        'One metre is 1 000 mm, so 1.2 metres is 1 200 mm.',
      ),
      QuizQuestion(
        'Which tool is best for checking that a corner is 90 degrees?',
        ['A try square', 'A hammer', 'A chisel', 'A paint brush'],
        0,
        'A try square or set square checks right angles.',
      ),
      QuizQuestion(
        'When you cut along a marked line, which side of the line should the saw blade normally remove?',
        [
          'The waste side of the line',
          'The middle of the piece you want to keep',
          'The side you want to keep',
          'It does not matter',
        ],
        0,
        'The blade removes material (the kerf). Cutting on the waste side keeps your piece at the right length.',
      ),
      QuizQuestion(
        'A 2.4 metre plank is cut into 3 equal pieces. Ignoring the saw cuts, how long is each piece?',
        ['60 cm', '80 cm', '100 cm', '120 cm'],
        1,
        '2 400 mm divided by 3 is 800 mm, which is 80 cm.',
      ),
      QuizQuestion(
        'What is a spirit level mainly used for?',
        [
          'Measuring length',
          'Checking that a surface is level or upright',
          'Marking curves',
          'Cutting angles',
        ],
        1,
        'The bubble shows whether a surface is level (horizontal) or plumb (vertical).',
      ),
    ],
  ),
  Quiz(
    'construction_safety',
    'masonry',
    'Construction safety',
    'Everyday site safety for builders and labourers.',
    'construction_safety',
    [
      QuizQuestion(
        'When is a hard hat most important?',
        [
          'Only when it is raining',
          'When there is a risk of falling objects or head bumps',
          'Only for visitors',
          'Never on small sites',
        ],
        1,
        'Head protection is needed wherever objects could fall or you could hit your head.',
      ),
      QuizQuestion(
        'What should you check before climbing a ladder?',
        [
          'That the ladder is in good condition and on firm, level ground',
          'That it is painted',
          'That the top is leaning on a loose pile of bricks',
          'Nothing, just climb',
        ],
        0,
        'Inspect the ladder and set it on firm ground. Keep three points of contact while climbing.',
      ),
      QuizQuestion(
        'Which is the safest way to lift a heavy bag of cement?',
        [
          'Bend at the waist with straight legs',
          'Bend your knees, keep your back straight and hold the load close to your body',
          'Twist while lifting',
          'Jerk it up quickly',
        ],
        1,
        'Use your legs, keep the load close and avoid twisting. Ask for help if it is too heavy.',
      ),
      QuizQuestion(
        'Why should you wear gloves and wash off wet cement quickly?',
        [
          'It can burn or irritate the skin',
          'It makes the cement set slower',
          'It improves the colour',
          'It has no effect on skin',
        ],
        0,
        'Wet cement is alkaline and can cause serious skin burns and irritation.',
      ),
      QuizQuestion(
        'What is the main danger of an unsupported trench wall?',
        [
          'It can collapse and bury workers',
          'It makes digging faster',
          'It gets warmer',
          'There is no danger',
        ],
        0,
        'Trench walls can collapse without warning. Support or slope the sides and keep spoil away from the edge.',
      ),
    ],
  ),
];

Quiz quizById(String id) =>
    kQuizzes.firstWhere((q) => q.id == id, orElse: () => kQuizzes.first);
