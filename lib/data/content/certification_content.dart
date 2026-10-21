import '../../models/models.dart';

/// Informational content only. Nothing here is an integration with TEVETA.
///
/// The TEVETA homepage URL below is listed as the authority's website on the
/// UNESCO-UNEVOC network page for TEVETA. Every other link is intentionally
/// left null so it can be configured once an official URL has been verified.
const kCertificationResources = <CertificationResource>[
  CertificationResource(
    'TEVETA website',
    'Technical Education, Vocational and Entrepreneurship Training Authority. Start here for official information on registered institutions and qualifications.',
    'https://www.teveta.org.zm/',
    verifiedOfficial: true,
  ),
  CertificationResource(
    'List of registered training institutions',
    'Ask TEVETA or check its website for the current list. Do not rely on an old copy.',
    null,
  ),
  CertificationResource(
    'Trade testing and assessment information',
    'Details of how experienced workers without certificates can be assessed. Link to be configured after it has been verified.',
    null,
  ),
];

const kWhyCertify = [
  'A recognised qualification can help clients and employers trust your skills.',
  'Some tenders, companies and public projects ask for formal certificates.',
  'Training can fill gaps in theory, safety and measurement that experience alone may miss.',
  'It can support your move from informal work to recognised work over time.',
];

/// General, non-binding guidance. It names no fees, dates or procedures.
const kTradeGuidance = <String, String>{
  'Plumbing':
      'Ask which plumbing programmes the provider offers, whether practical workshop time is included, and how your existing experience is assessed.',
  'Electrical work':
      'Electrical work carries safety and legal risks. Ask what licensing or registration applies to your level of work before you take on installations.',
  'Welding':
      'Ask which welding processes are covered, whether safety training is included, and whether you can be assessed on the processes you already use.',
  'Carpentry':
      'Ask if the course covers workshop machinery, reading drawings and estimating materials.',
  'Tailoring':
      'Ask whether pattern making, costing and running a small business are part of the course.',
  'Masonry and construction':
      'Ask about site safety training, reading plans and how practical skills are assessed.',
};

const kProviderQuestions = [
  'Is the institution registered with TEVETA right now? Can I see proof?',
  'Which qualification will I receive, and at which level?',
  'What are the total costs, including registration, materials and examination fees?',
  'How long does the programme take, and when are the next intakes?',
  'Can my current work experience count towards assessment?',
  'What are the entry requirements and which documents must I bring?',
  'Is there a part-time or weekend option if I need to keep working?',
  'How much of the course is hands-on practice?',
  'Are there bursaries, payment plans or support for young people?',
  'Where do graduates usually find work?',
];
