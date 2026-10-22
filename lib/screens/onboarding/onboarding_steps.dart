/// Layout type indicating where ads and elements are arranged in each step.
enum StepLayoutType {
  style, // Top Small Native Ad + 4 cards + Continue + Bottom Medium Native Ad
  vibe, // Options list + Next button + Bottom Medium Native Ad
  outfit, // Row 1 (2 items) + Medium Native Ad + Go Ahead button + Row 2 (2 items) + Bottom Banner
  calculator, // Top Small Native Ad + 4 items + Continue button + Bottom Banner
  surprise, // 2 cards + Medium Native Ad + Continue button
  avatarType, // Item 1 (Boy) + Medium Native Ad + Items 2 & 3 (Girl, Both) + Continue button
  contentLike, // Top row (3 items) + Medium Native Ad + Continue button + Bottom row (3 items)
  challengeMode, // Items 1-3 + Medium Native Ad + Next button + Item 4 + Bottom Banner
  wantMost, // 4 cards grid + Medium Native Ad + Go Ahead button
}

/// One option in an onboarding step.
class QuestionOption {
  final String iconAsset;
  final String label;
  final String? subtitle;

  const QuestionOption({
    required this.iconAsset,
    required this.label,
    this.subtitle,
  });
}

/// One onboarding step (question + options + button label + layout style).
class QuestionStep {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final StepLayoutType layoutType;
  final List<QuestionOption> options;

  const QuestionStep({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.layoutType,
    required this.options,
  });
}

/// The 9 onboarding questionnaire steps reconstructed directly from the video recording.
const List<QuestionStep> onboardingSteps = [
  // 1. What's Your Style?
  QuestionStep(
    title: "What's Your Style?",
    subtitle: 'Pick the vibe that matches you.',
    buttonLabel: 'Continue',
    layoutType: StepLayoutType.style,
    options: [
      QuestionOption(iconAsset: 'ic_i1', label: 'Casual'),
      QuestionOption(iconAsset: 'ic_i2', label: 'Trendy'),
      QuestionOption(iconAsset: 'ic_i3', label: 'Cool'),
      QuestionOption(iconAsset: 'ic_i4', label: 'Premium'),
    ],
  ),

  // 2. Pick your avatar vibe
  QuestionStep(
    title: 'Pick your avatar vibe',
    subtitle: 'Select up to Your vibes',
    buttonLabel: 'Next',
    layoutType: StepLayoutType.vibe,
    options: [
      QuestionOption(iconAsset: 'ic_i5', label: 'Street'),
      QuestionOption(iconAsset: 'ic_i6', label: 'Gamer'),
      QuestionOption(iconAsset: 'ic_i7', label: 'Royal'),
      QuestionOption(iconAsset: 'ic_i8', label: 'Funny'),
    ],
  ),

  // 3. Choose Your Outfit
  QuestionStep(
    title: 'Choose Your Outfit',
    subtitle: 'What You want to design first',
    buttonLabel: 'Go Ahead',
    layoutType: StepLayoutType.outfit,
    options: [
      QuestionOption(iconAsset: 'ic_tshirt', label: 'T-shirt'),
      QuestionOption(iconAsset: 'ic_shirt', label: 'Shirt'),
      QuestionOption(iconAsset: 'ic_pant', label: 'Pants'),
      QuestionOption(iconAsset: 'ic_shorts', label: 'Shorts'),
    ],
  ),

  // 4. Calculator
  QuestionStep(
    title: 'Calculator',
    subtitle: 'What do you want to calculate?',
    buttonLabel: 'Continue',
    layoutType: StepLayoutType.calculator,
    options: [
      QuestionOption(iconAsset: 'ic_rbx_to_dollar', label: 'RBX  USD', subtitle: 'Convert Robux to USD'),
      QuestionOption(iconAsset: 'ic_dollar_torbx', label: 'USD  RBX', subtitle: 'Convert USD to Robux'),
      QuestionOption(iconAsset: 'ic_onc_torbx', label: 'OBC  RBX', subtitle: 'Convert Obc to Robux'),
      QuestionOption(iconAsset: 'ic_daily', label: 'Daily RBX Calculator', subtitle: 'Check Daily Updates'),
    ],
  ),

  // 5. Pick Your Surprise
  QuestionStep(
    title: 'Pick Your Surprise',
    subtitle: 'Which One Would You Try First ?',
    buttonLabel: 'Continue',
    layoutType: StepLayoutType.surprise,
    options: [
      QuestionOption(iconAsset: 'ic_scratch', label: 'Scratch Card', subtitle: 'Reveal a fun Surprise'),
      QuestionOption(iconAsset: 'ic_spin', label: 'Lucky Spin', subtitle: 'Spin & Explore Rewards'),
    ],
  ),

  // 6. Choose Your Avatar Type
  QuestionStep(
    title: 'Choose Your Avatar Type',
    subtitle: 'Select the style that matches you (or try both)',
    buttonLabel: 'Continue',
    layoutType: StepLayoutType.avatarType,
    options: [
      QuestionOption(iconAsset: 'ic_i21', label: 'Boy', subtitle: 'Stylish & Cool'),
      QuestionOption(iconAsset: 'ic_i22', label: 'Girl', subtitle: 'Trendy & Cute'),
      QuestionOption(iconAsset: 'ic_i23', label: 'Both', subtitle: 'Explore All Styles'),
    ],
  ),

  // 7. What Content Do You Like ?
  QuestionStep(
    title: 'What Content Do You Like ?',
    subtitle: 'Choose One option',
    buttonLabel: 'Continue',
    layoutType: StepLayoutType.contentLike,
    options: [
      QuestionOption(iconAsset: 'ic_memes', label: 'Funny Memes'),
      QuestionOption(iconAsset: 'ic_lop', label: 'Tips & Tricks'),
      QuestionOption(iconAsset: 'ic_outfit_select', label: 'Outfit idea'),
      QuestionOption(iconAsset: 'ic_getdaily', label: 'Daily Update'),
      QuestionOption(iconAsset: 'ic_point_ch', label: 'Inspiration'),
      QuestionOption(iconAsset: 'ic_quiz', label: 'Quizzes'),
    ],
  ),

  // 8. Choose your challenge mode
  QuestionStep(
    title: 'Choose your challenge mode',
    subtitle: 'Pick one to start with',
    buttonLabel: 'Next',
    layoutType: StepLayoutType.challengeMode,
    options: [
      QuestionOption(iconAsset: 'ic_i30', label: 'Easy Quiz', subtitle: 'Fun & simple'),
      QuestionOption(iconAsset: 'ic_i31', label: 'Pro Quiz', subtitle: 'For smart players'),
      QuestionOption(iconAsset: 'ic_i32', label: 'Gaming Quiz', subtitle: 'Test your knowledge'),
      QuestionOption(iconAsset: 'ic_i33', label: 'Outfit Quiz', subtitle: 'Guess the style'),
    ],
  ),

  // 9. What Do You Want Most?
  QuestionStep(
    title: 'What Do You Want Most?',
    subtitle: 'Pick what you want help with first',
    buttonLabel: 'Go Ahead',
    layoutType: StepLayoutType.wantMost,
    options: [
      QuestionOption(iconAsset: 'ic_i34', label: 'Create Outfit', subtitle: 'Design amazing looks'),
      QuestionOption(iconAsset: 'ic_i35', label: 'Find New Styles', subtitle: 'Discover your vibe'),
      QuestionOption(iconAsset: 'ic_i36', label: 'Use RBX Tools', subtitle: 'Learn useful tools'),
      QuestionOption(iconAsset: 'ic_i37', label: 'Have Fun', subtitle: 'Play, explore, enjoy'),
    ],
  ),
];
