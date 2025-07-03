import 'package:flutter/material.dart';

class ServicesService {
  /// قائمة الخدمات الأساسية للشركة (ثابتة)
  static List<ServiceItem> getMainServices() {
    return [
      ServiceItem(
        id: 1,
        title: 'التسويق الإلكتروني',
        shortDescription: 'ضاعف مبيعاتك وحقق الانتشار عبر حملات تسويق إلكتروني احترافية.',
        description: '''
نقدم حلول تسويق إلكتروني متكاملة تساعدك على الوصول لجمهورك المستهدف وتحقيق نتائج ملموسة من خلال:
- إدارة الحملات الإعلانية على جميع المنصات
- تحسين ظهورك في محركات البحث
- بناء استراتيجية محتوى فعالة
- تحليل الأداء وتقديم تقارير دورية
''',
        icon: Icons.campaign,
      ),
      ServiceItem(
        id: 2,
        title: 'خدمات الاعلانات',
        shortDescription: 'إعلانات ذكية تحقق لك أفضل عائد على الاستثمار.',
        description: '''
نصمم وننفذ حملات إعلانية رقمية مبتكرة تضمن لك:
- استهداف دقيق لجمهورك
- زيادة المبيعات والتحويلات
- تعزيز الوعي بعلامتك التجارية
- تقارير أداء مفصلة وشفافة
''',
        icon: Icons.ads_click,
      ),
      ServiceItem(
        id: 3,
        title: 'ادارة وتأمين السيرفرات',
        shortDescription: 'أمان واستقرار لمواقعك وسيرفراتك على مدار الساعة.',
        description: '''
فريقنا التقني يضمن لك:
- مراقبة السيرفرات بشكل مستمر
- حماية متقدمة ضد الهجمات والاختراقات
- حلول نسخ احتياطي واستعادة سريعة
- دعم فني متواصل 24/7
''',
        icon: Icons.security,
      ),
      ServiceItem(
        id: 4,
        title: 'تصميم الهوية والجرافيك',
        shortDescription: 'هوية بصرية تميزك وتبني ثقة جمهورك.',
        description: '''
نبتكر لك هوية متكاملة تشمل:
- تصميم الشعار والهوية البصرية
- تصاميم سوشيال ميديا احترافية
- فيديوهات موشن جرافيك جذابة
- مواد دعائية مطبوعة ورقمية
''',
        icon: Icons.brush,
      ),
      ServiceItem(
        id: 5,
        title: 'الاستشارات',
        shortDescription: 'استشارات تقنية واستراتيجية تدفع عملك للنجاح.',
        description: '''
نقدم لك خبراتنا في:
- تحليل وتطوير الأعمال
- اختيار الحلول التقنية الأنسب
- بناء خطط تسويقية فعالة
- دعم اتخاذ القرار التقني والإداري
''',
        icon: Icons.support_agent,
      ),
      ServiceItem(
        id: 6,
        title: 'تطوير تطبيقات الهاتف الذكي',
        shortDescription: 'تطبيقات عصرية تعزز حضورك الرقمي وتخدم عملاءك.',
        description: '''
نطور تطبيقات مخصصة تلبي احتياجاتك:
- برمجة تطبيقات أندرويد وiOS
- تصميم واجهات استخدام جذابة وسهلة
- ربط التطبيق بأنظمة شركتك
- دعم فني وتحديثات مستمرة
''',
        icon: Icons.phone_android,
      ),
      ServiceItem(
        id: 7,
        title: 'تحسين نتائج محركات البحث (SEO)',
        shortDescription: 'تصدر نتائج البحث واجذب عملاء جدد يومياً.',
        description: '''
نرفع ترتيب موقعك في جوجل عبر:
- تحسين تقني شامل للموقع
- بناء روابط خارجية قوية
- كتابة محتوى متوافق مع السيو
- تقارير شهرية مفصلة
''',
        icon: Icons.trending_up,
      ),
      ServiceItem(
        id: 8,
        title: 'تصميم المواقع الالكترونية',
        shortDescription: 'موقع احترافي يعكس علامتك التجارية ويحقق أهدافك.',
        description: '''
نصمم ونبرمج مواقع عصرية:
- قوالب حصرية متوافقة مع جميع الأجهزة
- سرعة تحميل عالية وتجربة مستخدم ممتازة
- تكامل مع وسائل الدفع والشحن
- دعم فني وتطوير مستمر
''',
        icon: Icons.web,
      ),
    ];
  }
}

class ServiceItem {
  final int id;
  final String title;
  final String shortDescription;
  final String description;
  final IconData icon;

  ServiceItem({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.icon,
  });
} 