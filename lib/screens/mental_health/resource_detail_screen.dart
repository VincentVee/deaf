import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceDetailScreen extends StatelessWidget {
  final String title;
  final String category;
  final IconData icon;
  final Color color;

  const ResourceDetailScreen({
    super.key,
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: color),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About this resource',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(_getDescription(title)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Online Resources',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._getOnlineResources(title).map((resource) =>
                        _buildResourceLink(context, resource)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommended Videos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._getVideos(title).map((video) =>
                        _buildVideoLink(context, video)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Related Articles',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._getArticles(title).map((article) =>
                        _buildArticleLink(context, article)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceLink(BuildContext context, Map<String, String> resource) {
    return ListTile(
      leading: const Icon(Icons.link, color: Colors.blue),
      title: Text(resource['title']!),
      subtitle: Text(resource['url']!),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () => _launchURL(context, resource['url']!),
    );
  }

  Widget _buildVideoLink(BuildContext context, Map<String, String> video) {
    return ListTile(
      leading: const Icon(Icons.play_circle, color: Colors.red),
      title: Text(video['title']!),
      subtitle: Text(video['duration']!),
      trailing: const Icon(Icons.arrow_forward, size: 16),
      onTap: () => _launchURL(context, video['url']!),
    );
  }

  Widget _buildArticleLink(BuildContext context, Map<String, String> article) {
    return ListTile(
      leading: const Icon(Icons.article, color: Colors.green),
      title: Text(article['title']!),
      subtitle: Text('${article['source']!} • ${article['readTime']!}'),
      trailing: const Icon(Icons.arrow_forward, size: 16),
      onTap: () => _launchURL(context, article['url']!),
    );
  }

  String _getDescription(String title) {
    switch (title) {
      case 'Understanding Anxiety':
        return 'Learn about anxiety disorders, symptoms, and evidence-based coping strategies. This resource provides comprehensive information to help you understand and manage anxiety effectively.';
      case 'Deaf Mental Health Resources':
        return 'Specialized mental health resources created specifically for the deaf and hard-of-hearing community, including sign language therapy options and deaf-friendly counseling services.';
      case 'Stress Management Tips':
        return 'Practical techniques and strategies to manage stress in daily life. Learn about mindfulness, relaxation techniques, and lifestyle changes that can reduce stress levels.';
      case 'Building Resilience':
        return 'Develop the ability to bounce back from adversity. Discover tools and techniques to build mental strength, emotional flexibility, and long-term resilience.';
      case 'Sign Language Therapy':
        return 'Access therapy services conducted in sign language. Learn about mental health support designed specifically for deaf individuals by professionals fluent in sign language.';
      default:
        return 'Access mental health resources and support services designed for your well-being.';
    }
  }

  List<Map<String, String>> _getOnlineResources(String title) {
    final Map<String, List<Map<String, String>>> resources = {
      'Understanding Anxiety': [
        {'title': 'Anxiety & Depression Association of America', 'url': 'https://adaa.org'},
        {'title': 'National Institute of Mental Health - Anxiety', 'url': 'https://www.nimh.nih.gov/health/topics/anxiety-disorders'},
        {'title': 'Mental Health America - Anxiety', 'url': 'https://mhanational.org/conditions/anxiety'},
      ],
      'Deaf Mental Health Resources': [
        {'title': 'NAD Mental Health Services', 'url': 'https://www.nad.org/resources/health/mental-health/'},
        {'title': 'Deaf Counseling Center', 'url': 'https://deafcounseling.com'},
        {'title': 'National Deaf Therapy', 'url': 'https://nationaldeaftherapy.com'},
      ],
      'Stress Management Tips': [
        {'title': 'Mayo Clinic - Stress Management', 'url': 'https://www.mayoclinic.org/healthy-lifestyle/stress-management'},
        {'title': 'HelpGuide - Stress Management', 'url': 'https://www.helpguide.org/articles/stress/stress-management.htm'},
        {'title': 'CDC - Coping with Stress', 'url': 'https://www.cdc.gov/mentalhealth/stress-coping/index.html'},
      ],
      'Building Resilience': [
        {'title': 'American Psychological Association - Resilience', 'url': 'https://www.apa.org/topics/resilience'},
        {'title': 'Verywell Mind - Resilience Building', 'url': 'https://www.verywellmind.com/resilience-building-mental-strength-5157668'},
        {'title': 'Positive Psychology - Resilience', 'url': 'https://positivepsychology.com/resilience-activities-exercises/'},
      ],
      'Sign Language Therapy': [
        {'title': 'ASL Therapy Directory', 'url': 'https://www.asltherapy.com'},
        {'title': 'Deaf Mental Health Support', 'url': 'https://www.deafmentalhealth.org'},
        {'title': 'Sign Language Counseling Network', 'url': 'https://www.signlanguagecounseling.org'},
      ],
    };
    return resources[title] ?? resources['Understanding Anxiety']!;
  }

  List<Map<String, String>> _getVideos(String title) {
    final Map<String, List<Map<String, String>>> videos = {
      'Understanding Anxiety': [
        {'title': 'Understanding Anxiety (with ASL)', 'duration': '15:30', 'url': 'https://www.youtube.com/results?search_query=anxiety+asl'},
        {'title': 'Coping with Anxiety - Mental Health Education', 'duration': '12:45', 'url': 'https://www.youtube.com/results?search_query=coping+with+anxiety'},
      ],
      'Deaf Mental Health Resources': [
        {'title': 'Mental Health Resources for Deaf Community (ASL)', 'duration': '20:15', 'url': 'https://www.youtube.com/results?search_query=deaf+mental+health+resources+asl'},
        {'title': 'Deaf Mental Health Awareness', 'duration': '18:30', 'url': 'https://www.youtube.com/results?search_query=deaf+mental+health+awareness'},
      ],
      'Stress Management Tips': [
        {'title': '5 Minute Stress Relief (with ASL)', 'duration': '5:00', 'url': 'https://www.youtube.com/results?search_query=stress+relief+asl'},
        {'title': 'Mindfulness for Stress Reduction', 'duration': '10:20', 'url': 'https://www.youtube.com/results?search_query=mindfulness+stress+reduction'},
      ],
      'Building Resilience': [
        {'title': 'Building Mental Resilience (ASL Interpretation)', 'duration': '25:00', 'url': 'https://www.youtube.com/results?search_query=building+resilience+asl'},
        {'title': 'Resilience Strategies for Daily Life', 'duration': '15:45', 'url': 'https://www.youtube.com/results?search_query=resilience+strategies'},
      ],
      'Sign Language Therapy': [
        {'title': 'Therapy in Sign Language', 'duration': '22:30', 'url': 'https://www.youtube.com/results?search_query=sign+language+therapy'},
        {'title': 'ASL Mental Health Support Session', 'duration': '30:00', 'url': 'https://www.youtube.com/results?search_query=asl+mental+health+support'},
      ],
    };
    return videos[title] ?? videos['Understanding Anxiety']!;
  }

  List<Map<String, String>> _getArticles(String title) {
    final Map<String, List<Map<String, String>>> articles = {
      'Understanding Anxiety': [
        {'title': 'Complete Guide to Anxiety Disorders', 'source': 'Psychology Today', 'readTime': '10 min read', 'url': 'https://www.psychologytoday.com/us/basics/anxiety'},
        {'title': 'Natural Ways to Reduce Anxiety', 'source': 'Healthline', 'readTime': '8 min read', 'url': 'https://www.healthline.com/nutrition/ways-to-reduce-anxiety'},
      ],
      'Deaf Mental Health Resources': [
        {'title': 'Mental Health Care for Deaf Individuals', 'source': 'NAD', 'readTime': '12 min read', 'url': 'https://www.nad.org/resources/health/mental-health/'},
        {'title': 'Deaf-Friendly Therapy Options', 'source': 'Verywell Health', 'readTime': '7 min read', 'url': 'https://www.verywellhealth.com/deaf-therapy-5192595'},
      ],
      'Stress Management Tips': [
        {'title': '31 Stress Management Techniques', 'source': 'Positive Psychology', 'readTime': '15 min read', 'url': 'https://positivepsychology.com/stress-management-techniques/'},
        {'title': 'Quick Stress Relief Strategies', 'source': 'HelpGuide', 'readTime': '6 min read', 'url': 'https://www.helpguide.org/articles/stress/quick-stress-relief.htm'},
      ],
      'Building Resilience': [
        {'title': 'How to Build Resilience', 'source': 'APA', 'readTime': '10 min read', 'url': 'https://www.apa.org/topics/resilience'},
        {'title': '10 Ways to Build Resilience', 'source': 'Verywell Mind', 'readTime': '8 min read', 'url': 'https://www.verywellmind.com/ways-to-build-resilience-5189731'},
      ],
      'Sign Language Therapy': [
        {'title': 'Finding Sign Language Therapy', 'source': 'Healthline', 'readTime': '9 min read', 'url': 'https://www.healthline.com/health/sign-language-therapy'},
        {'title': 'ASL Mental Health Resources Directory', 'source': 'Deaf-Hearing', 'readTime': '11 min read', 'url': 'https://www.deaf-hearing.org/mental-health'},
      ],
    };
    return articles[title] ?? articles['Understanding Anxiety']!;
  }

  // ✅ SIMPLE WORKING URL LAUNCHER
  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);

    // Direct launch without any checks - simplest approach
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}