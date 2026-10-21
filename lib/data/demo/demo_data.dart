import '../../core/constants/constants.dart';
import '../../models/models.dart';

/// Clearly fictional demonstration records. Seed data lives here, away from
/// application logic. IDs are stable so seeding twice never duplicates records.
const kDemoClientId = 'u_demo_client';
const kDemoClientName = 'Natasha Phiri';
const kDefaultDemoWorkerId = 'w_david';
const kMyWorkerId = 'w_me';

class DemoSeed {
  final List<WorkerProfile> workers;
  final List<Job> jobs;
  final List<JobApplication> applications;
  final List<Booking> bookings;
  final List<Review> reviews;
  final List<Conversation> conversations;
  final List<NotificationItem> notifications;
  const DemoSeed({
    required this.workers,
    required this.jobs,
    required this.applications,
    required this.bookings,
    required this.reviews,
    required this.conversations,
    required this.notifications,
  });

  static const _colors = [
    0xFFEAF0F6, 0xFFE8F1EC, 0xFFF3EEE4, 0xFFECE9F4, 0xFFF4E9EA, 0xFFE6F0F3,
  ];
  static const _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  static WorkerProfile _w({
    required String id,
    required String name,
    required String trade,
    required String town,
    String hood = '',
    required int years,
    required double rating,
    required int reviews,
    required List<String> skills,
    required String bio,
    required String service,
    List<String> days = _allDays,
    double? price,
    PricingType pricing = PricingType.fixedQuote,
    bool verified = false,
    List<String> badges = const [],
    List<PortfolioItem> portfolio = const [],
    bool available = true,
    String level = 'Intermediate',
    int colorIndex = 0,
  }) =>
      WorkerProfile(
        id: id,
        name: name,
        bio: bio,
        tradeId: trade,
        skills: skills.map((s) => Skill(s, level)).toList(),
        years: years,
        serviceDescription: service,
        skillLevel: level,
        province: provinceOfTown(town),
        town: town,
        neighbourhood: hood,
        radiusKm: 20,
        willingToTravel: true,
        days: days,
        startingPrice: price,
        pricingType: pricing,
        isAvailable: available,
        portfolio: portfolio,
        baseRating: rating,
        baseReviews: reviews,
        verifiedHistory: verified,
        quizBadgeIds: badges,
        isDemo: true,
        colorValue: _colors[colorIndex % _colors.length],
      );

  static PortfolioItem _p(String id, String title, String desc, String trade, String date) =>
      PortfolioItem(id: id, title: title, description: desc, tradeId: trade, completedOn: date);

  static DemoSeed build(DateTime now) {
    DateTime ago({int d = 0, int h = 0, int m = 0}) =>
        now.subtract(Duration(days: d, hours: h, minutes: m));

    final workers = <WorkerProfile>[
      _w(
        id: 'w_david', name: 'David Mwamba', trade: 'plumbing', town: 'Lusaka', hood: 'Woodlands',
        years: 5, rating: 4.8, reviews: 24, price: 150,
        skills: ['Pipe fitting', 'Leak repair', 'Bathroom installation', 'Problem solving'],
        bio: 'Experienced plumber with 5+ years in residential and commercial plumbing. I learned on site from a master plumber and I take pride in clean, leak-free work.',
        service: 'Bathroom and kitchen installations, leak repairs, geyser fitting and drain unblocking.',
        verified: true, badges: ['plumbing_basics'], level: 'Advanced', colorIndex: 0,
        portfolio: [
          _p('pf_d1', 'Bathroom renovation, Woodlands', 'Replaced old pipes, installed a new basin, toilet and shower mixer.', 'plumbing', '2026-08-14'),
          _p('pf_d2', 'Kitchen sink and tap fitting', 'Installed a double sink with new waste pipes.', 'plumbing', '2026-07-02'),
          _p('pf_d3', 'Leak repair in a roof tank line', 'Traced and fixed a hidden leak in a tank feed pipe.', 'plumbing', '2026-05-20'),
        ],
      ),
      _w(
        id: 'w_grace', name: 'Grace Chisenga', trade: 'electrical', town: 'Lusaka', hood: 'Chilenje',
        years: 4, rating: 4.7, reviews: 18, price: 200,
        skills: ['House wiring', 'Lighting installation', 'Fault finding'],
        bio: 'Electrician focused on safe domestic wiring, lighting and repairs. I always isolate and test before I start.',
        service: 'New wiring, socket and switch repairs, lighting installation and fault finding.',
        verified: true, badges: ['electrical_safety'], level: 'Advanced', colorIndex: 1,
        portfolio: [
          _p('pf_g1', 'Three bedroom house rewire', 'Replaced old cabling and fitted a new distribution board.', 'electrical', '2026-08-01'),
          _p('pf_g2', 'Security lights installation', 'Fitted outdoor security lights around a home.', 'electrical', '2026-06-18'),
        ],
      ),
      _w(
        id: 'w_samuel', name: 'Samuel Banda', trade: 'carpentry', town: 'Ndola', hood: 'Northrise',
        years: 6, rating: 4.6, reviews: 12, price: 250,
        skills: ['Wardrobes', 'Kitchen cabinets', 'Doors and frames'],
        bio: 'Carpenter who builds practical furniture and fitted cabinets for homes and small shops.',
        service: 'Built-in wardrobes, kitchen cabinets, doors, window frames and repairs.',
        badges: ['carpentry_foundations'], colorIndex: 2, verified: true,
        portfolio: [
          _p('pf_s1', 'Fitted wardrobe, two doors', 'Measured, built and installed a floor-to-ceiling wardrobe.', 'carpentry', '2026-07-22'),
          _p('pf_s2', 'Kitchen cabinets', 'Eight cabinet units with soft-close hinges.', 'carpentry', '2026-05-09'),
        ],
      ),
      _w(
        id: 'w_patrick', name: 'Patrick Mulenga', trade: 'welding', town: 'Kitwe', hood: 'Parklands',
        years: 5, rating: 4.5, reviews: 10, price: 300,
        skills: ['Gates and burglar bars', 'Window frames', 'Metal repairs'],
        bio: 'Welder who learned from a master fabricator. Clean joints, straight frames and safe working habits.',
        service: 'Gates, burglar bars, window frames, trailers and general metal repair.',
        badges: ['welding_safety'], colorIndex: 3,
        portfolio: [
          _p('pf_p1', 'Sliding gate', 'Fabricated and installed a steel sliding gate.', 'welding', '2026-06-30'),
        ],
      ),
      _w(
        id: 'w_brian', name: 'Brian Phiri', trade: 'plumbing', town: 'Lusaka', hood: 'Kabulonga',
        years: 3, rating: 4.4, reviews: 8, price: 120,
        skills: ['Blocked drains', 'Tap repair', 'Pipe fitting'],
        bio: 'Plumber for homes and small offices. Quick response for leaks and blocked drains.',
        service: 'Drain unblocking, tap and toilet repair, small pipe jobs.', colorIndex: 4,
      ),
      _w(
        id: 'w_mercy', name: 'Mercy Zulu', trade: 'tailoring', town: 'Livingstone', hood: 'Dambwa',
        years: 7, rating: 4.9, reviews: 31, price: 80,
        skills: ['School uniforms', 'Dress making', 'Chitenge outfits', 'Alterations'],
        bio: 'Tailor with seven years of experience sewing uniforms, wedding outfits and everyday wear.',
        service: 'Custom clothing, uniforms in bulk and alterations.', verified: true, colorIndex: 5,
        level: 'Advanced',
        portfolio: [
          _p('pf_m1', 'Wedding party chitenge outfits', 'Eight matching outfits finished in two weeks.', 'tailoring', '2026-08-30'),
        ],
      ),
      _w(
        id: 'w_joyce', name: 'Joyce Tembo', trade: 'hair_beauty', town: 'Kabwe', hood: 'Bwacha',
        years: 3, rating: 4.6, reviews: 15, price: 100,
        skills: ['Braiding', 'Weaves', 'Natural hair care'],
        bio: 'Hair stylist specialising in braids and protective styles. I can also work from your home.',
        service: 'Braiding, weaves, wash and style.', colorIndex: 0, days: ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      ),
      _w(
        id: 'w_chola', name: 'Chola Kapambwe', trade: 'painting', town: 'Kitwe', hood: 'Nkana East',
        years: 4, rating: 4.3, reviews: 9, price: 180,
        skills: ['Interior painting', 'Exterior painting', 'Wall preparation'],
        bio: 'Painter who takes time on preparation so the finish lasts.',
        service: 'Interior and exterior painting for homes and shops.', colorIndex: 1,
      ),
      _w(
        id: 'w_moses', name: 'Moses Lungu', trade: 'masonry', town: 'Chipata', hood: 'Kapata',
        years: 8, rating: 4.5, reviews: 20, price: 350, pricing: PricingType.daily,
        skills: ['Bricklaying', 'Plastering', 'Boundary walls'],
        bio: 'Mason with eight years on residential building sites. I lead a small crew of three.',
        service: 'Foundations, brickwork, plastering and boundary walls.', badges: ['construction_safety'],
        verified: true, colorIndex: 2, level: 'Advanced',
      ),
      _w(
        id: 'w_kelvin', name: 'Kelvin Sakala', trade: 'mechanics', town: 'Solwezi', hood: 'Kyawama',
        years: 6, rating: 4.4, reviews: 11, price: 250,
        skills: ['General servicing', 'Brake repair', 'Engine diagnostics'],
        bio: 'Motor mechanic for light vehicles and pickups.', colorIndex: 3,
        service: 'Servicing, brake and suspension repair and diagnostics.', days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      ),
      _w(
        id: 'w_agness', name: 'Agness Mwale', trade: 'cleaning', town: 'Lusaka', hood: 'Roma',
        years: 2, rating: 4.2, reviews: 7, price: 150,
        skills: ['Home cleaning', 'Office cleaning', 'Carpet cleaning'],
        bio: 'Reliable cleaner for homes and small offices.', colorIndex: 4,
        service: 'Regular and once-off cleaning.', available: false, level: 'Beginner',
      ),
      _w(
        id: 'w_peter', name: 'Peter Hamoonga', trade: 'appliance', town: 'Choma', hood: 'Town Centre',
        years: 5, rating: 4.6, reviews: 14, price: 120,
        skills: ['Fridge repair', 'Washing machine repair', 'Air conditioner servicing'],
        bio: 'Appliance technician. I diagnose first, then quote.', colorIndex: 5,
        service: 'Repairs and servicing of home appliances.',
      ),
      _w(
        id: 'w_ruth', name: 'Ruth Nyirenda', trade: 'gardening', town: 'Ndola', hood: 'Kansenshi',
        years: 3, rating: 4.1, reviews: 6, price: 100, pricing: PricingType.daily,
        skills: ['Lawn care', 'Tree trimming', 'Garden design'],
        bio: 'Gardener who keeps compounds neat and healthy.', colorIndex: 0,
        service: 'Lawn care, hedge trimming and garden clean ups.', level: 'Beginner',
      ),
      _w(
        id: 'w_isaac', name: 'Isaac Chanda', trade: 'electrical', town: 'Kitwe', hood: 'Chimwemwe',
        years: 7, rating: 4.8, reviews: 27, price: 220,
        skills: ['House wiring', 'Solar installation', 'Fault finding'],
        bio: 'Electrician with seven years on homes and small businesses.', colorIndex: 1,
        service: 'Wiring, solar set ups and repairs.', badges: ['electrical_safety'], verified: true,
        level: 'Advanced',
      ),
      _w(
        id: 'w_bwalya', name: 'Bwalya Mutale', trade: 'welding', town: 'Lusaka', hood: 'Matero',
        years: 9, rating: 4.7, reviews: 33, price: 280,
        skills: ['Steel structures', 'Gates and burglar bars', 'Metal repairs'],
        bio: 'Welder and fabricator with nine years of workshop and site experience.',
        service: 'Structural steel, gates, carports and repairs.', badges: ['welding_safety'], verified: true,
        colorIndex: 2, level: 'Advanced',
      ),
    ];

    final jobs = <Job>[
      Job(id: 'j_1', title: 'Fix leaking kitchen tap', tradeId: 'plumbing', town: 'Lusaka', neighbourhood: 'Woodlands',
          description: 'The mixer tap under the kitchen window drips all day and the base is wet. Needs repair or replacement.',
          urgency: JobUrgency.soon, budgetMin: 150, budgetMax: 300, clientId: kDemoClientId, clientName: kDemoClientName,
          postedAt: ago(d: 1), isDemo: true, completeBy: _iso(now.add(const Duration(days: 5)))),
      Job(id: 'j_2', title: 'Install ceiling lights in three bedrooms', tradeId: 'electrical', town: 'Lusaka', neighbourhood: 'Kabulonga',
          description: 'New house. Cables are in the ceiling, we need fittings installed and tested.',
          urgency: JobUrgency.flexible, budgetMin: 600, budgetMax: 900, clientId: 'c_thandiwe', clientName: 'Thandiwe Kunda',
          postedAt: ago(d: 2), isDemo: true),
      Job(id: 'j_3', title: 'Build wardrobe and kitchen cabinets', tradeId: 'carpentry', town: 'Ndola', neighbourhood: 'Itawa',
          description: 'Floor-to-ceiling wardrobe in the main bedroom and six kitchen cabinets.',
          urgency: JobUrgency.flexible, budgetMin: 3000, budgetMax: 5000, clientId: 'c_joseph', clientName: 'Joseph Mumba',
          postedAt: ago(d: 3), isDemo: true),
      Job(id: 'j_4', title: 'Weld gate and window frames', tradeId: 'welding', town: 'Kitwe', neighbourhood: 'Riverside',
          description: 'One double gate and four window frames for a new house.',
          urgency: JobUrgency.soon, budgetMin: 2500, budgetMax: 4000, clientId: 'c_mwila', clientName: 'Mwila Bwalya',
          postedAt: ago(d: 4), isDemo: true),
      Job(id: 'j_5', title: 'Sew 12 school uniforms', tradeId: 'tailoring', town: 'Livingstone', neighbourhood: 'Maramba',
          description: 'Twelve primary school uniforms before the new term starts.',
          urgency: JobUrgency.urgent, budgetMin: 1200, budgetMax: 1800, clientId: 'c_thandiwe', clientName: 'Thandiwe Kunda',
          postedAt: ago(h: 20), isDemo: true),
      Job(id: 'j_6', title: 'Paint 3 bedroom house interior', tradeId: 'painting', town: 'Kabwe', neighbourhood: 'Makululu',
          description: 'Two coats on walls and ceilings. Client supplies paint.',
          urgency: JobUrgency.flexible, budgetMin: 1500, budgetMax: 2500, clientId: 'c_joseph', clientName: 'Joseph Mumba',
          postedAt: ago(d: 5), isDemo: true),
      Job(id: 'j_7', title: 'Replace bathroom mixer and shower', tradeId: 'plumbing', town: 'Lusaka', neighbourhood: 'Woodlands',
          description: 'Replace an old mixer and shower head. Completed last week.',
          urgency: JobUrgency.flexible, budgetMin: 300, budgetMax: 500, clientId: kDemoClientId, clientName: kDemoClientName,
          postedAt: ago(d: 14), status: JobStatus.completed, isDemo: true),
      Job(id: 'j_8', title: 'Service two air conditioners', tradeId: 'appliance', town: 'Choma', neighbourhood: 'Town Centre',
          description: 'Annual service for two split units in a small office.',
          urgency: JobUrgency.soon, budgetMin: 400, budgetMax: 700, clientId: 'c_mwila', clientName: 'Mwila Bwalya',
          postedAt: ago(d: 2), isDemo: true),
      Job(id: 'j_9', title: 'Unblock bathroom drain', tradeId: 'plumbing', town: 'Lusaka', neighbourhood: 'Chilenje',
          description: 'Shower drain is very slow and smells.',
          urgency: JobUrgency.urgent, budgetMin: 100, budgetMax: 250, clientId: 'c_thandiwe', clientName: 'Thandiwe Kunda',
          postedAt: ago(h: 6), isDemo: true),
    ];

    final applications = <JobApplication>[
      JobApplication(id: 'a_1', jobId: 'j_1', workerId: 'w_david', message: 'I can come tomorrow morning with a spare cartridge.', appliedAt: ago(h: 20)),
      JobApplication(id: 'a_2', jobId: 'j_1', workerId: 'w_brian', message: 'Available this week, I can bring a new mixer tap.', appliedAt: ago(h: 14)),
      JobApplication(id: 'a_3', jobId: 'j_7', workerId: 'w_david', status: ApplicationStatus.accepted, message: 'I will bring all fittings.', appliedAt: ago(d: 13)),
      JobApplication(id: 'a_4', jobId: 'j_9', workerId: 'w_brian', message: 'Nearby, can be there within the hour.', appliedAt: ago(h: 3)),
    ];

    final bookings = <Booking>[
      Booking(id: 'b_1', workerId: 'w_david', clientId: kDemoClientId, clientName: kDemoClientName,
          service: 'Install new basin and tap', description: 'Replace the old basin in the guest bathroom.',
          preferredDate: now.add(const Duration(days: 3)), preferredTime: '10:00', location: 'Woodlands, Lusaka',
          budget: 400, createdAt: ago(h: 5), isDemo: true),
      Booking(id: 'b_2', workerId: 'w_grace', clientId: kDemoClientId, clientName: kDemoClientName,
          service: 'Rewire socket outlets', description: 'Three sockets in the living room are loose.',
          preferredDate: now.add(const Duration(days: 2)), preferredTime: '09:00', location: 'Woodlands, Lusaka',
          status: BookingStatus.accepted, createdAt: ago(d: 1), isDemo: true),
      Booking(id: 'b_3', workerId: 'w_grace', clientId: kDemoClientId, clientName: kDemoClientName,
          service: 'Fix tripping circuit breaker', description: 'Breaker tripped whenever the kettle was on.',
          preferredDate: now.subtract(const Duration(days: 9)), preferredTime: '14:00', location: 'Woodlands, Lusaka',
          status: BookingStatus.completed, createdAt: ago(d: 12), isDemo: true),
      Booking(id: 'b_4', workerId: 'w_david', clientId: 'c_thandiwe', clientName: 'Thandiwe Kunda',
          service: 'Unblock kitchen drain', description: 'Water drains very slowly.',
          preferredDate: now, preferredTime: '08:30', location: 'Chilenje, Lusaka',
          status: BookingStatus.inProgress, createdAt: ago(d: 1), isDemo: true),
    ];

    Review r(String id, String w, String name, int stars, String text, String ctx, int daysAgo, List<String> tags) =>
        Review(id: id, workerId: w, clientId: 'c_$id', clientName: name, rating: stars, text: text,
            tags: tags, createdAt: ago(d: daysAgo), contextId: 'demo_$id', contextLabel: ctx, isDemo: true);

    final reviews = <Review>[
      r('r1', 'w_david', 'Chanda M.', 5, 'Fixed a leak that two other plumbers could not find. Tidy and honest about the price.', 'Leak repair', 20, ['Quality work', 'Fair price']),
      r('r2', 'w_david', 'Thandiwe K.', 5, 'Arrived on time and finished the bathroom in one day.', 'Bathroom installation', 45, ['On time', 'Professional']),
      r('r3', 'w_david', 'Joseph M.', 4, 'Good work. Slightly late but he called ahead.', 'Pipe fitting', 70, ['Good communication']),
      r('r4', 'w_david', 'Mwila B.', 5, 'Very polite and cleaned up after the job.', 'Tap installation', 95, ['Tidy worksite']),
      r('r5', 'w_grace', 'Natasha P.', 5, 'Explained everything and tested each circuit.', 'Socket repair', 30, ['Professional']),
      r('r6', 'w_grace', 'Peter S.', 4, 'Solid wiring job at a fair price.', 'Lighting installation', 60, ['Fair price']),
      r('r7', 'w_grace', 'Ruth C.', 5, 'Found the fault quickly.', 'Fault finding', 85, ['Quality work']),
      r('r8', 'w_samuel', 'Elias N.', 5, 'The wardrobe fits perfectly.', 'Fitted wardrobe', 25, ['Quality work']),
      r('r9', 'w_samuel', 'Bessie K.', 4, 'Nice cabinets, took one day longer than planned.', 'Kitchen cabinets', 80, ['Quality work']),
      r('r10', 'w_patrick', 'Ireen L.', 5, 'Strong gate, clean welds.', 'Sliding gate', 33, ['Quality work']),
      r('r11', 'w_mercy', 'Doreen S.', 5, 'Uniforms were ready early and fit well.', 'School uniforms', 18, ['On time']),
      r('r12', 'w_mercy', 'Mutinta H.', 5, 'Beautiful finishing on the outfits.', 'Dress making', 55, ['Quality work']),
    ];

    final conversations = <Conversation>[
      Conversation(id: 'cv_1', workerId: 'w_david', clientId: kDemoClientId, clientName: kDemoClientName,
          unreadForClient: 1, messages: [
        Message(id: 'm1', fromWorker: false, text: 'Hello David, are you free on Thursday for a basin installation?', at: ago(h: 6)),
        Message(id: 'm2', fromWorker: true, text: 'Hello Natasha. Yes, I can come at 10:00. Please send a photo of the current basin.', at: ago(h: 5)),
      ]),
      Conversation(id: 'cv_2', workerId: 'w_grace', clientId: kDemoClientId, clientName: kDemoClientName, messages: [
        Message(id: 'm3', fromWorker: true, text: 'I have accepted your request. I will arrive at 09:00 with my testing tools.', at: ago(d: 1)),
        Message(id: 'm4', fromWorker: false, text: 'Thank you Grace. See you then.', at: ago(h: 22)),
      ]),
      Conversation(id: 'cv_3', workerId: 'w_david', clientId: 'c_thandiwe', clientName: 'Thandiwe Kunda',
          unreadForWorker: 2, messages: [
        Message(id: 'm5', fromWorker: false, text: 'Good morning, are you able to unblock a drain today?', at: ago(h: 3)),
        Message(id: 'm6', fromWorker: false, text: 'It is in Chilenje. I can pay on completion.', at: ago(h: 2)),
      ]),
    ];

    NotificationItem n(String id, UserRole role, NotifType t, String title, String body, DateTime at,
            {bool read = false, String? route}) =>
        NotificationItem(id: id, forRole: role, type: t, title: title, body: body, at: at, read: read, route: route);

    final notifications = <NotificationItem>[
      n('n1', UserRole.worker, NotifType.jobMatch, 'New job match', 'Unblock bathroom drain in Chilenje matches your trade.', ago(h: 6), route: '/job/j_9'),
      n('n2', UserRole.worker, NotifType.serviceRequest, 'New service request', 'Natasha Phiri asked you to install a basin and tap.', ago(h: 5), route: '/booking/b_1'),
      n('n3', UserRole.worker, NotifType.message, 'New message', 'Thandiwe Kunda sent you a message.', ago(h: 2), route: '/chat/cv_3'),
      n('n4', UserRole.worker, NotifType.applicationStatus, 'Application accepted', 'Your application for "Replace bathroom mixer and shower" was accepted.', ago(d: 13), read: true, route: '/job/j_7'),
      n('n5', UserRole.worker, NotifType.quiz, 'Badge earned', 'You earned the Plumbing Basics badge.', ago(d: 30), read: true, route: '/badges'),
      n('n6', UserRole.client, NotifType.application, 'New applications', '2 workers applied to "Fix leaking kitchen tap".', ago(h: 14), route: '/job/j_1'),
      n('n7', UserRole.client, NotifType.booking, 'Booking accepted', 'Grace Chisenga accepted your request to rewire sockets.', ago(d: 1), route: '/booking/b_2'),
      n('n8', UserRole.client, NotifType.message, 'New message', 'David Mwamba replied to your message.', ago(h: 5), route: '/chat/cv_1'),
      n('n9', UserRole.client, NotifType.reviewReminder, 'Leave a review', 'How did the work go with Grace Chisenga? Share a review.', ago(d: 8), route: '/review/b_3?workerId=w_grace'),
      n('n10', UserRole.client, NotifType.reviewReminder, 'Leave a review', 'Your bathroom mixer job is complete. Review David Mwamba.', ago(d: 7), route: '/review/j_7?workerId=w_david'),
    ];

    return DemoSeed(
      workers: workers,
      jobs: jobs,
      applications: applications,
      bookings: bookings,
      reviews: reviews,
      conversations: conversations,
      notifications: notifications,
    );
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
