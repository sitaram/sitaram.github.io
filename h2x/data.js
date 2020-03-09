var root = "How to X";
var baseTreeVersion = 1;  // Bumping this loses local data and rebootstraps.

// BOOTSTRAP
var baseTree = [
  {
    query: 'Example 1: Get a drivers license',
    subtopics: [
      { query: 'Overview' },
      { query: 'Types of drivers licence' },
      { query: 'First time vs. renewal' },
      { query: 'Basic steps' },
      { query: 'Make a DMV appointment' },
      { query: 'What to take to the DMV' },
      { query: 'Do I need a Real ID' },
      { query: 'Study for a drivers test' },
    ]
  },

  {
    query: 'Example 2: Learn chess',
    subtopics: [
      {
        query: 'Pieces & movement',
        subtopics: [
          { query: 'How to set up a chess board' },
          { query: 'How the chess pawn moves' },
          { query: 'How the chess rook moves' },
          { query: 'How the chess bishop moves' },
          { query: 'How the chess knight moves' },
          { query: 'How the chess king moves' },
          { query: 'How the chess queen moves' },
        ]
      },
      {
        query: 'Objective',
        subtopics: [
          { query: 'What is a check in chess' },
          { query: 'What is a checkmate' },
          { query: 'What is a stalemate' },
        ]
      },
      {
        query: 'Advanced moves',
        subtopics: [
          { query: 'Castling in chess' },
          { query: 'En passant in chess' },
          { query: 'Promotion in chess' },
        ]
      },
      {
        query: 'Tactics',
        subtopics: [
          { query: 'Forks in chess' },
          { query: 'Skewers in chess' },
          { query: 'Pinned pieces in chess' },
        ]
      },
      {
        query: 'Strategy',
        subtopics: [
          { query: 'Developing pieces in chess' },
          { query: 'Rook lifts in chess' },
          { query: 'Doubled rooks in chess' },
          { query: 'Bishop pairs in chess' },
          { query: 'Battery in chess' },
        ]
      },
      {
        query: 'Openings',
        subtopics: [
          { query: 'Ruy lopez opening' },
          { query: 'Sicilian opening' },
          { query: 'French opening' },
          { query: 'English opening' },
        ]
      },
      {
        query: 'Endgames',
        subtopics: [
          { query: 'Queen/king endgame' },
          { query: 'Rook/king endgame' },
          { query: 'Bishop endgame' },
          { query: 'Knight endgame' },
        ]
      },
    ],
  },

  { query: 'Example 3: Get student loan forgiveness',
    subtopics: [
      { query: 'What is it' },
      {
        query: 'Career-based methods',
        subtopics: [
          { query: 'Become a teacher' },
          { query: 'Become a doctor or a lawyer' },
          { query: 'Volunteer for a non-profit' },
          { query: 'Join the military' },
          { query: 'Public service' },
        ]
      },
      { query: 'Income-based methods' },
      {
        query: 'Other methods',
        subtopics: [
          'Permanent disability',
        ]
      }
    ]
  },

  { query: 'Calculate college cost' },
  { query: 'Apply for fafsa' },
  { query: 'Get scholarships' },
  { query: 'Get student loans' },
  { query: 'Transfer financial aid funds' },
  { query: 'Understand my award letter' },
  { query: 'Get an application fee waiver' },
  { query: 'Retain qualification for student loan' },
  { query: 'Refinance a student loan' },
  { query: 'Manage student debt' },
];
