// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Viora';

  @override
  String get home => 'Home';

  @override
  String get habits => 'Habits';

  @override
  String get plant => 'Plant';

  @override
  String get stats => 'Stats';

  @override
  String get profile => 'Profile';

  @override
  String get grow => 'Grow';

  @override
  String get navMe => 'Me';

  @override
  String get insights => 'Insights';

  @override
  String get viewInsights => 'Charts and progress over time';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String daysStreak(int count) {
    return '$count day streak';
  }

  @override
  String get keepItUp => 'Keep it up! 💪';

  @override
  String get best => 'Best';

  @override
  String get yourPlant => 'Your Plant';

  @override
  String get plantWilted => 'Check-in to revive your plant! 💧';

  @override
  String get plantNotWatered => 'Plant hasn\'t been watered for 3 days...';

  @override
  String get completeHabitsToGrow => 'Complete habits to grow your plant!';

  @override
  String get today => 'Today';

  @override
  String completed(int done, int total) {
    return '$done/$total';
  }

  @override
  String get noHabitsYet => 'No habits yet. Add one now! ✨';

  @override
  String get allDoneToday => 'Amazing! You\'ve completed everything today 🎉';

  @override
  String habitsRemaining(int count) {
    return '$count habits remaining';
  }

  @override
  String get quote1 => 'Small steps every day lead to big changes. 💪';

  @override
  String get quote2 => 'Good habits are the foundation of a healthy life. 🌿';

  @override
  String get quote3 => 'Persistence is the key to success. 🗝️';

  @override
  String get quote4 => 'Better than yesterday is good enough. ✨';

  @override
  String get quote5 => 'Health is the most valuable asset. 🏃';

  @override
  String get myPlant => 'My Plant';

  @override
  String level(int level) {
    return 'Level $level';
  }

  @override
  String levelRange(int current, int next) {
    return 'Level $current → $next';
  }

  @override
  String points(int count) {
    return '$count points';
  }

  @override
  String get totalPoints => 'Total Points';

  @override
  String get levelProgress => 'Level';

  @override
  String get maxLevel => '🏆 Plant reached max level!';

  @override
  String get developmentProgress => 'Development Progress';

  @override
  String get developmentRoadmap => 'Development Roadmap';

  @override
  String get howToEarnPoints => 'How to Earn Points';

  @override
  String get earnTip1 => '✅ Complete ≥ 1 habit per day';

  @override
  String get earnReward1 => '+1 point';

  @override
  String get earnTip2 => '✅ Complete ≥ 50% habits per day';

  @override
  String get earnReward2 => '+2 points';

  @override
  String get earnTip3 => '🏆 Complete 100% habits per day';

  @override
  String get earnReward3 => '+3 points';

  @override
  String get earnTip4 => '⚠️ No check-in for 3 consecutive days';

  @override
  String get earnReward4 => 'Plant wilts';

  @override
  String get congratulations => '🎉 CONGRATULATIONS! 🎉';

  @override
  String get plantLeveledUp => 'Your plant leveled up!';

  @override
  String get keepGrowing => '✨ Keep growing! ✨';

  @override
  String get treasureUnlocked => '🏆 Magic Water';

  @override
  String get treasureLocked => '🔒 Locked';

  @override
  String get plantLevel1 => 'Seed';

  @override
  String get plantLevel2 => 'Sprouting Seed';

  @override
  String get plantLevel3 => 'Sprout';

  @override
  String get plantLevel4 => 'Seedling';

  @override
  String get plantLevel5 => 'Young Plant';

  @override
  String get plantLevel6 => 'Small Plant';

  @override
  String get plantLevel7 => 'Growing Plant';

  @override
  String get plantLevel8 => 'Mature Plant';

  @override
  String get plantLevel9 => 'Thriving Plant';

  @override
  String get plantLevel10 => 'Flowering Plant';

  @override
  String get plantLevel11 => 'Young Fruit';

  @override
  String get plantLevel12 => 'Growing Fruit';

  @override
  String get plantLevel13 => 'Ripe Fruit';

  @override
  String get plantLevel14 => 'Abundant Fruit';

  @override
  String get plantLevel15 => 'Perfect Mature Plant';

  @override
  String get plantWiltedWarning => 'Plant is wilting! Check-in now 💧';

  @override
  String get plantWiltingStatus => '😢 Plant is wilting...';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked / $total achievements';
  }

  @override
  String get allAchievementsUnlocked => 'You\'ve unlocked them all! 🎉';

  @override
  String achievementsRemaining(int count) {
    return '$count achievements remaining';
  }

  @override
  String get achievementFirstStep => 'First Step';

  @override
  String get achievementFirstStepDesc => 'Complete your first check-in';

  @override
  String get achievementStreak3 => '3-Day Streak';

  @override
  String get achievementStreak3Desc => 'Maintain a 3-day streak';

  @override
  String get achievementStreak7 => 'Week Warrior';

  @override
  String get achievementStreak7Desc => 'Maintain a 7-day streak';

  @override
  String get achievementStreak30 => 'Monthly Master';

  @override
  String get achievementStreak30Desc => 'Maintain a 30-day streak';

  @override
  String get achievementHabits5 => 'Multitasker';

  @override
  String get achievementHabits5Desc => 'Create 5 habits';

  @override
  String get achievementCheckin50 => 'Half Century';

  @override
  String get achievementCheckin50Desc => 'Complete 50 check-ins';

  @override
  String get achievementCheckin100 => 'Centurion';

  @override
  String get achievementCheckin100Desc => 'Complete 100 check-ins';

  @override
  String get achievementPlantLevel3 => 'Young Plant';

  @override
  String get achievementPlantLevel3Desc => 'Reach plant level 3';

  @override
  String get achievementPlantLevel5 => 'Garden Paradise';

  @override
  String get achievementPlantLevel5Desc => 'Reach maximum plant level';

  @override
  String get notificationSettingsTitle => 'Habit Reminders';

  @override
  String get notificationInfo =>
      'Notifications will remind you to check-in daily habits to help your plant grow.';

  @override
  String get morningReminder => 'Morning Reminder';

  @override
  String get morningReminderDesc => 'Start your day with healthy habits';

  @override
  String get eveningReminder => 'Evening Reminder';

  @override
  String get eveningReminderDesc => 'Complete habits before bed';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get usingDarkMode => 'Using dark mode';

  @override
  String get usingLightMode => 'Using light mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get savedSettings => 'Settings saved and applied';

  @override
  String get logout => 'Logout';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get notUpdated => 'Not updated';

  @override
  String get birthYear => 'Birth Year';

  @override
  String get bodyStats => 'Body Stats';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get bmi => 'BMI';

  @override
  String get underweight => 'Underweight';

  @override
  String get normal => 'Normal';

  @override
  String get overweight => 'Overweight';

  @override
  String get obese => 'Obese';

  @override
  String get personalGoals => 'Personal Goals';

  @override
  String get goals => 'Goals';

  @override
  String get noGoalsSelected => 'No goals selected';

  @override
  String get security => 'Security';

  @override
  String get changePassword => 'Change Password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm new password';

  @override
  String get forgotPassword => 'Forgot current password? Reset via email →';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordUpdated => 'Password updated successfully';

  @override
  String get failed => 'Failed';

  @override
  String get achievements => 'Achievements';

  @override
  String get myAchievements => 'My Achievements';

  @override
  String get viewUnlockedAchievements => 'View unlocked achievements';

  @override
  String get habitReminders => 'Habit Reminders';

  @override
  String get setDailyReminders => 'Set daily reminder times';

  @override
  String get appearance => 'Appearance';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageChanged => 'Switched to Vietnamese. Restart app to apply.';

  @override
  String get languageChangedEn => 'Switched to English. Restart app to apply.';

  @override
  String get editName => 'Edit Name';

  @override
  String get save => 'Save';

  @override
  String get nameUpdated => 'Name updated';

  @override
  String get bodyStatsTitle => 'Body Stats';

  @override
  String get heightRange => 'Height from 100–250 cm';

  @override
  String get weightRange => 'Weight from 15–300 kg';

  @override
  String get statsUpdated => 'Stats updated';

  @override
  String get goalsUpdated => 'Goals updated';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get loginTitle => 'LOGIN';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get password => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterFullName => 'Enter full name';

  @override
  String get enterPasswordAgain => 'Re-enter password';

  @override
  String get minEightChars => 'Minimum 8 characters';

  @override
  String get forgotPasswordQuestion => 'Forgot password?';

  @override
  String get or => 'or';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get registerNow => 'Register now';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get loginNow => 'Login';

  @override
  String get quote =>
      '\"Change doesn\'t come from big things,\\nbut from small habits repeated every day.\"';

  @override
  String get pleaseEnterAllInfo => 'Please enter all information';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get loginFailedRetry => 'Login failed, please try again';

  @override
  String get googleLoginFailed => 'Google login failed';

  @override
  String googleLoginError(String error) {
    return 'Google login error: $error';
  }

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get pleaseEnterName => 'Please enter name';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordMinEightChars => 'Password must be at least 8 characters';

  @override
  String get passwordNeedsUppercase => 'Must have at least 1 uppercase letter';

  @override
  String get passwordNeedsNumber => 'Must have at least 1 number';

  @override
  String get pleaseConfirmPassword => 'Please confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get weWillSendOtp => 'We will send a 6-digit OTP code to your email';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String enterOtpSentTo(String email) {
    return 'Enter OTP sent to $email';
  }

  @override
  String get newPasswordMinEight => 'New password (minimum 8 characters)';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get otpSent => 'OTP has been sent to your email';

  @override
  String get otpMustBeSixDigits => 'OTP must be 6 digits';

  @override
  String get confirmPasswordMismatch => 'Confirm password does not match';

  @override
  String get resetPasswordSuccess => 'Password reset successfully!';

  @override
  String get stepEmail => 'Email';

  @override
  String get stepConfirm => 'Confirm';

  @override
  String get habitsToday => 'Today\'s Habits';

  @override
  String get confirmCompletion => 'Confirm Completion';

  @override
  String get confirmHabitMessage =>
      'Are you sure you completed this habit today?\n\nOnce confirmed, you cannot uncheck it today.';

  @override
  String get notSure => 'Not sure';

  @override
  String get completedExclaim => 'Completed!';

  @override
  String get deleteHabit => 'Delete Habit?';

  @override
  String confirmDeleteHabit(String name) {
    return 'Are you sure you want to delete \\\"$name\\\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String unlockedOn(String date) {
    return 'Unlocked on $date';
  }

  @override
  String get addNewHabit => 'Add New Habit';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get habitName => 'Habit Name';

  @override
  String get habitNameExample => 'E.g.: Drink 2L water daily';

  @override
  String get category => 'Category';

  @override
  String get addHabit => 'Add Habit';

  @override
  String get noHabits => 'No habits yet';

  @override
  String get addFirstHabit =>
      'Add your first habit to start\\nyour healthy living journey';

  @override
  String get amazingAllDone => 'Amazing! All done 🎉';

  @override
  String get yourToday => 'Your Today';

  @override
  String get habitsLabel => 'habits';

  @override
  String consecutiveDays(int count) {
    return '$count consecutive days';
  }

  @override
  String get categoryEat => 'Eating';

  @override
  String get categoryExercise => 'Exercise';

  @override
  String get categorySleep => 'Sleep';

  @override
  String get categoryMental => 'Mental';

  @override
  String get categoryHydration => 'Hydration';

  @override
  String get categoryOther => 'Other';

  @override
  String get metricWater => 'Water (ml)';

  @override
  String get metricDistance => 'Distance (m)';

  @override
  String get metricSleepHours => 'Sleep hours';

  @override
  String get metricCalories => 'Calories';

  @override
  String get enterNumberOptional => 'Enter number (optional)';

  @override
  String get unitMl => 'ml';

  @override
  String get unitM => 'm';

  @override
  String get unitHours => 'hours';

  @override
  String get unitCal => 'cal';

  @override
  String get onboardingWhoAreYou => 'Who are you?';

  @override
  String get onboardingPersonalize => 'Help us personalize for you';

  @override
  String get onboardingBirthYear => 'Birth year?';

  @override
  String get onboardingAgeRecommendation =>
      'To provide age-appropriate recommendations';

  @override
  String get onboardingBodyStats => 'Body Stats';

  @override
  String get onboardingOptionalLater => 'Optional — can update later';

  @override
  String get onboardingYourGoals => 'Your goals?';

  @override
  String get onboardingSelectGoals => 'Select one or more goals';

  @override
  String get onboardingChoosePlant => 'Choose your plant';

  @override
  String get onboardingPlantCompanion => 'Your companion on this journey';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next →';

  @override
  String get startJourney => 'Start Journey 🌱';

  @override
  String get enterBirthYear => 'Enter birth year (e.g.: 1995)';

  @override
  String get quickSelect => 'Quick select:';

  @override
  String get invalidBirthYear => 'Invalid birth year';

  @override
  String get birthYearBefore1930 => 'Birth year cannot be before 1930';

  @override
  String get mustBeAtLeast10 => 'You must be at least 10 years old';

  @override
  String get heightLabel => 'Height';

  @override
  String get weightLabel => 'Weight';

  @override
  String get heightExample => 'Example: 165';

  @override
  String get weightExample => 'Example: 55';

  @override
  String get unitCm => 'cm';

  @override
  String get unitKg => 'kg';

  @override
  String get bmiInfo =>
      'This information helps calculate BMI and provide better habit recommendations.';

  @override
  String get invalidHeight => 'Invalid height';

  @override
  String get heightMin => 'Minimum height 100 cm';

  @override
  String get heightMax => 'Maximum height 250 cm';

  @override
  String get invalidWeight => 'Invalid weight';

  @override
  String get weightMin => 'Minimum weight 15 kg';

  @override
  String get weightMax => 'Maximum weight 300 kg';

  @override
  String get goalEatHealthy => 'Eat Healthy';

  @override
  String get goalExercise => 'Exercise';

  @override
  String get goalSleep => 'Sleep';

  @override
  String get goalMental => 'Mental Health';

  @override
  String get goalWeight => 'Weight';

  @override
  String get goalHydration => 'Hydration';

  @override
  String get goalOther => 'Other';

  @override
  String get whatIsYourGoal => 'What is your goal?';

  @override
  String get plantSprout => 'Green Sprout';

  @override
  String get plantCactus => 'Cactus';

  @override
  String get plantBonsai => 'Bonsai';

  @override
  String get plantFlower => 'Cherry Blossom';

  @override
  String get plantBamboo => 'Bamboo';

  @override
  String get plantSunflower => 'Sunflower';

  @override
  String get plantDescSprout => 'Small but full of potential';

  @override
  String get plantDescCactus => 'Resilient, never gives up';

  @override
  String get plantDescBonsai => 'Patient, steady progress';

  @override
  String get plantDescFlower => 'Bright and full of energy';

  @override
  String get plantDescBamboo => 'Flexible, persistent every day';

  @override
  String get plantDescSunflower => 'Always facing the light';

  @override
  String get onboardingPlantGrowWithHabits =>
      'Your plant will grow with your habits';

  @override
  String get onboardingPlantTip =>
      'Complete habits daily to grow your plant and unlock new achievements!';

  @override
  String get notifMorningTitle => '🌱 Good morning!';

  @override
  String get notifMorningBody => 'Are you ready for your habits today?';

  @override
  String get notifEveningTitle => '🌙 Evening Reminder';

  @override
  String get notifEveningBody =>
      'Don\'t forget to complete your habits today! Your plant is waiting 🌿';

  @override
  String get notifChannelMorning => 'Morning Reminder';

  @override
  String get notifChannelEvening => 'Evening Reminder';

  @override
  String get notifChannelMorningDesc => 'Morning habit reminders';

  @override
  String get notifChannelEveningDesc => 'Evening habit reminders';

  @override
  String get notifDailyReminder => 'Daily habit reminders';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get details => 'Details';

  @override
  String get totalCheckins => 'Total Check-ins';

  @override
  String get activeDaysLabel => 'Active Days';

  @override
  String get longestStreakLabel => 'Best';

  @override
  String get habitsCount => 'Habits';

  @override
  String get days => 'days';

  @override
  String get habitsCompletedDaily => 'Habits completed daily';

  @override
  String get habitsCompleted30Days => 'Habits completed in 30 days';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get completeHabitsToSeeStats => 'Complete habits to see statistics';

  @override
  String get noHabitsYetStats => 'No habits yet';

  @override
  String get createHabitsToSeeStats =>
      'Create habits to see detailed statistics';

  @override
  String get timesCheckin => 'check-ins';

  @override
  String get totalLabel => 'Total';

  @override
  String get byCategory => 'By Category';

  @override
  String get completionPercentageDaily => 'Daily habit completion percentage';

  @override
  String get good => 'Good';

  @override
  String get fair => 'Fair';

  @override
  String get needsImprovement => 'Needs Improvement';

  @override
  String get goodPercent => 'Good (≥80%)';

  @override
  String get fairPercent => 'Fair (≥50%)';

  @override
  String get needsImprovementPercent => 'Needs Improvement';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get consecutiveDaysLabel => 'consecutive days';

  @override
  String get greatKeepGoing => 'Great! Keep it up! 💪';

  @override
  String get maintainDaily => 'Keep it up every day! 🌟';

  @override
  String get activityCalendar30Days => '30-Day Activity Calendar';

  @override
  String get darkerMoreHabits => 'Darker = more habits completed';

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get quantityLabel => 'Number of habits completed daily';

  @override
  String get trendOver7Days => 'Trend Over Time';

  @override
  String get trendSubtitle => 'Daily recorded values (P*)';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get sevenDays => '7 days';

  @override
  String get thirtyDays => '30 days';

  @override
  String get ninetyDays => '90 days';

  @override
  String get currentStreakLabel => '🔥 Current Streak';

  @override
  String get longestStreakDetail => '🏆 Longest Streak';

  @override
  String get totalCheckinsLabel => '✅ Total Check-ins';

  @override
  String get times => 'times';

  @override
  String get trendOverTime => 'Trend Over Time';

  @override
  String get dailyRecordedValues => 'Daily recorded values';

  @override
  String dailyRecordedValuesWithUnit(String unit) {
    return 'Daily recorded values ($unit)';
  }

  @override
  String get average => '📊 Average';

  @override
  String get totalSum => '📈 Total';

  @override
  String get noDataForPeriod => 'No data for this period';

  @override
  String get startTrackingHabit => 'Start tracking habit to see chart';

  @override
  String get community => 'Community';

  @override
  String get shareYourProgress => 'Share your progress...';

  @override
  String get photo => 'Photo';

  @override
  String get achievement => 'Achievement';

  @override
  String get trending => 'Trending';

  @override
  String get following => 'Following';

  @override
  String get followUser => 'Follow';

  @override
  String get followingUser => 'Following';

  @override
  String get friends => 'Friends';

  @override
  String get retry => 'Retry';

  @override
  String get loadFeedError => 'Could not load posts';

  @override
  String get followingTabEmpty => 'Follow others to see their posts here';

  @override
  String get noSearchResults => 'No posts found';

  @override
  String get searchCommunity => 'Search posts or users...';

  @override
  String get noPosts => 'No posts yet';

  @override
  String get createFirstPost => 'Be the first to share!';

  @override
  String get createPost => 'Create Post';

  @override
  String get postContent => 'Post Content';

  @override
  String get shareYourThoughts => 'Share your thoughts...';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get publish => 'Publish';

  @override
  String likes(int count) {
    return '$count likes';
  }

  @override
  String comments(int count) {
    return '$count comments';
  }

  @override
  String get share => 'Share';

  @override
  String get writeComment => 'Write a comment...';

  @override
  String get writeReply => 'Write a reply...';

  @override
  String get reply => 'Reply';

  @override
  String get replies => 'Replies';

  @override
  String viewReplies(int count) {
    return 'View $count replies';
  }

  @override
  String get hideReplies => 'Hide replies';

  @override
  String get send => 'Send';

  @override
  String get deletePost => 'Delete Post?';

  @override
  String get confirmDeletePost => 'Are you sure you want to delete this post?';

  @override
  String get postDeleted => 'Post deleted';

  @override
  String get postCreated => 'Post created successfully!';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String get completeProfileBanner =>
      'Complete your profile for better recommendations';

  @override
  String get completeProfileBannerAction => 'Tap to continue setup';

  @override
  String get tapToAddFirstHabit => 'Tap to add your first habit →';

  @override
  String get streakBrokenTitle => 'Streak reset';

  @override
  String get streakBrokenBody =>
      'That\'s okay — every day is a fresh start. Complete a habit today to grow your plant!';

  @override
  String get startFreshStreak => 'Start again';

  @override
  String get firstCheckInTitle => 'Awesome! 🎉';

  @override
  String get firstCheckInBody =>
      'You completed your first check-in. See your plant grow!';

  @override
  String get firstCheckInStatsHint =>
      'Tip: tap the stats icon on the Habits tab to see your progress and streaks.';

  @override
  String get viewHabitStats => 'View stats';

  @override
  String get gotIt => 'Got it';

  @override
  String get habitCreatedSuccess => 'Habit added!';

  @override
  String get afterFirstHabitTitle => 'What\'s next? 🌱';

  @override
  String get afterFirstHabitBody =>
      'Tap your new habit below to mark it done for today — your plant will grow!';

  @override
  String get completeHabitToday => 'Mark done for today';

  @override
  String get goToTodayTab => 'Go to Today';

  @override
  String get addAnotherHabit => 'Add another habit';

  @override
  String get afterOnboardingNoHabitsTitle => 'Create your first habit';

  @override
  String get afterOnboardingNoHabitsBody =>
      'Your profile is ready. Add 1–2 habits to start your daily routine.';

  @override
  String get createFirstHabit => 'Create my first habit';

  @override
  String get tapHabitToCompleteHint => 'Tap a habit to complete it for today';

  @override
  String get onboardingStarterHabitsTitle => 'Pick habits for today';

  @override
  String get onboardingStarterHabitsSubtitle =>
      'Based on your goals — you can change them anytime';

  @override
  String get onboardingStarterHabitsHint =>
      'Select at least 1 habit to get started';

  @override
  String get starterHabitHydration2L => 'Drink 2L of water';

  @override
  String get starterHabitWalk20 => 'Walk 20 minutes';

  @override
  String get starterHabitExercise30 => 'Exercise 30 minutes';

  @override
  String get starterHabitSleep23 => 'Sleep before 11 PM';

  @override
  String get starterHabitMeditation10 => 'Meditate 10 minutes';

  @override
  String get starterHabitHealthyBreakfast => 'Healthy breakfast';

  @override
  String get starterHabitEatVeggies => 'Eat vegetables & fruit';

  @override
  String get starterHabitRead30 => 'Read for 30 minutes';

  @override
  String get starterHabitStudy60 => 'Study for 1 hour';

  @override
  String get starterHabitReviewNotes => 'Review notes for 15 minutes';

  @override
  String get onboardingReadyCheckHabits =>
      'Your habits are ready — tap one to complete today!';

  @override
  String get viewYourPlant => 'View plant';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get habitUpdated => 'Habit updated';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get noNotificationsHint =>
      'Achievements and reminders will appear here';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get followers => 'Followers';

  @override
  String get posts => 'Posts';

  @override
  String get viewProfile => 'View Profile';

  @override
  String notifLike(String name) {
    return '$name liked your post';
  }

  @override
  String notifComment(String name) {
    return '$name commented on your post';
  }

  @override
  String notifFollow(String name) {
    return '$name started following you';
  }

  @override
  String get tapToChangeAvatar => 'Tap to change avatar';

  @override
  String get avatarUpdated => 'Avatar updated successfully';

  @override
  String get avatarUpdateFailed => 'Failed to update avatar';

  @override
  String get searchResultsUsers => 'Users';

  @override
  String get searchResultsPosts => 'Posts';

  @override
  String get shareAchievement => 'Share Achievement';

  @override
  String get achievementShared => 'Achievement shared to community!';

  @override
  String get noSearchResultsUsers => 'No users found';
}
