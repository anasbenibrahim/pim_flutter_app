# 🔔 HopeUp — Système de Notifications de Risque IA

> **À destination de l'équipe de développement**  
> Ce document décrit l'architecture complète et les étapes de configuration de la fonctionnalité de détection de risque par IA et de notification des membres de la famille.

---

## 🗺️ Architecture du pipeline

```
Flutter App (Patient)
       │
       │ POST /webhook/hopeup-risk-check
       ▼
  Ngrok (tunnel HTTPS)
       │
       ▼
   n8n (orchestrateur)
       │
       ├─── POST /predict ──────► ML Service (FastAPI, port 8001)
       │                               │ Retourne risk_score, risk_level
       │◄──────────────────────────────┘
       │
       │ Si intervention_needed = true
       │
       └─── POST /api/v1/notifications/risk-alert ──► Spring Boot (port 8080)
                                                           │
                                                           │ Sauvegarde Notification
                                                           │ pour chaque FamilyMember
                                                           ▼
                                                      Base de données PostgreSQL
                                                           │
                                                           ▼
                                                  Flutter App (Famille) 🔔
```

---

## 📁 Fichiers concernés

| Composant | Fichier |
|-----------|---------|
| Flutter — Service de risque | `pim_flutter_app/lib/core/services/risk_assessment_service.dart` |
| Flutter — Service de notifs | `pim_flutter_app/lib/core/services/notification_service.dart` |
| Flutter — Page de notifs | `pim_flutter_app/lib/features/notifications/pages/notifications_page.dart` |
| Flutter — Constantes API | `pim_flutter_app/lib/core/constants/api_constants.dart` |
| n8n — Workflow | `n8n_workflow.json` |
| ML Service | `ml_service.py` |
| Spring — Contrôleur | `pim_spring_app/.../controller/NotificationController.java` |
| Spring — Service | `pim_spring_app/.../service/NotificationService.java` |
| Spring — Modèle | `pim_spring_app/.../model/Notification.java` |
| Spring — Repository (notif) | `pim_spring_app/.../repository/NotificationRepository.java` |
| Spring — Repository (famille) | `pim_spring_app/.../repository/FamilyMemberRepository.java` |
| Spring — Sécurité | `pim_spring_app/.../config/SecurityConfig.java` |

---

## ⚙️ Étape 1 — Configuration de l'IP locale

> **Important :** Chaque développeur doit mettre **son adresse IP locale** (IPv4 de la carte réseau physique, pas VMware).

### Trouver votre IP :
```powershell
ipconfig
```
Cherchez la ligne **"Connexion au réseau local** → **Adresse IPv4**" (ex: `192.168.98.163`).

### Mettre à jour `api_constants.dart` :
```dart
// lib/core/constants/api_constants.dart
if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
  return 'http://VOTRE_IP:8080/api';  // ← Remplacez ici
}
```

### Mettre à jour `n8n_workflow.json` :
Dans le nœud `Trigger Spring Alert`, l'URL doit pointer vers votre IP :
```json
"url": "http://VOTRE_IP:8080/api/v1/notifications/risk-alert"
```

---

## ⚙️ Étape 2 — Lancer le service ML

### Prérequis :
- Python 3.x installé
- Dépendances : `fastapi`, `uvicorn`, `tensorflow`, `scikit-learn`, `joblib`, `pandas`, `numpy`

```powershell
pip install fastapi uvicorn tensorflow scikit-learn joblib pandas numpy
```

### Lancer le service :
```powershell
cd c:\Users\omaym\AndroidProjects\pim
py ml_service.py --port 8001
```

Le service sera accessible sur `http://0.0.0.0:8001`.

**Endpoint :** `POST /predict`  
**Corps de la requête (exemple) :**
```json
{
  "screen_1_health_goal": "Complete sobriety",
  "screen_2_gender": "Female",
  "screen_3_mood": 1,
  "screen_4_sleep_quality": "Worst",
  "screen_5_stress_level": 5,
  "screen_6_professional_help": 0,
  "screen_7_medications": 0,
  "screen_8_physical_symptoms": ["Fatigue"],
  "screen_9_personality": ["Overthinking"],
  "screen_10_mental_health": ["Anxiety", "Depression"],
  "addiction_type": ["Other"],
  "days_in_recovery": 30
}
```
**Réponse :**
```json
{
  "risk_score": 90.3,
  "risk_level": "Critical",
  "days_to_crisis": 3.2,
  "intervention_needed": true
}
```

> **Note :** Les avertissements `InconsistentVersionWarning` de scikit-learn sont normaux et n'impactent pas le fonctionnement.

---

## ⚙️ Étape 3 — Configurer Ngrok

> Ngrok crée un tunnel HTTPS public vers votre n8n local.

### Compte Ngrok :
- URL fixe utilisée : `https://ghostily-dashy-palmira.ngrok-free.dev`
- Cette URL est configurée dans `risk_assessment_service.dart` et doit pointer vers **votre tunnel personnel** si vous utilisez votre propre compte.

### Lancer Ngrok :
```powershell
ngrok http 5678
```
Assurez-vous que la session est active avant de lancer des tests.

Pour utiliser l'URL **fixe** (ngrok free tier ne garantit pas une URL fixe) :
```powershell
ngrok http --domain=ghostily-dashy-palmira.ngrok-free.dev 5678
```

---

## ⚙️ Étape 4 — Configurer n8n

### Lancer n8n :
```powershell
npx n8n start
```
Interface accessible sur `http://localhost:5678`.

### Importer le workflow :

1. Dans n8n, cliquez sur `+ Add Workflow`
2. Menu (`...`) → **Import from file**
3. Sélectionnez `n8n_workflow.json`
4. **Mettez à jour l'URL** du nœud `Trigger Spring Alert` avec votre IP locale
5. Cliquez sur **Publish** (bouton vert en haut à droite)

### Structure du workflow V4 :

| Nœud | Type | Description |
|------|------|-------------|
| `Webhook` | Webhook | Reçoit les données du questionnaire Flutter |
| `Call ML API` | HTTP Request | Envoie les données au service ML (port 8001) |
| `Risk Check` | IF | `intervention_needed == true` → déclenche l'alerte |
| `Trigger Spring Alert` | HTTP Request | POST vers Spring Boot pour créer la notification |

> **Webhook URL :** `https://[votre-ngrok]/webhook/hopeup-risk-check`

---

## ⚙️ Étape 5 — Configuration Spring Boot

### Endpoint de notification (déjà implémenté) :
`POST /api/v1/notifications/risk-alert` — **Accès public** (sans JWT)

```java
// NotificationController.java
@PostMapping("/risk-alert")
public ResponseEntity<Void> triggerRiskAlert(@RequestBody RiskAlertRequest request) {
    notificationService.triggerRiskAlert(
        request.getPatientId(), 
        request.getRiskLevel(), 
        request.getRiskScore()
    );
    return ResponseEntity.ok().build();
}
```

### Corps de la requête attendu :
```json
{
  "patientId": 26,
  "riskLevel": "Critical",
  "riskScore": 90.3
}
```

### Sécurité (SecurityConfig.java) :
L'endpoint de risque est accessible sans authentification :
```java
.requestMatchers("/api/v1/notifications/risk-alert").permitAll()
```

### Récupération des notifications (Flutter) :
`GET /api/v1/notifications` — **Accès authentifié (JWT Bearer)**

La réponse contient :
```json
[
  {
    "id": 1,
    "title": "Alerte de Risque : aa aa",
    "content": "Le système HopeUp a détecté un risque critical (Score: 90.3%)...",
    "type": "RISK_ALERT",
    "read": false,
    "createdAt": "2026-02-27T02:52:59"
  }
]
```

> **Important :** Le champ `user` (entité JPA) est annoté `@JsonIgnore` pour éviter la sérialisation circulaire.

---

## ⚙️ Étape 6 — Flutter : Intégration

### Déclenchement (côté Patient) :
Le questionnaire dans `AssessmentPage` appelle automatiquement :
```dart
await RiskAssessmentService().analyzeRisk(
  user: user,           // Contient user.id (patient_id)
  moodLevel: ...,
  stressLevel: ...,
  // ...
);
```

### Affichage (côté Famille) :
Les notifications s'affichent sur `NotificationsPage`, accessible via :
- La 🔔 en haut à droite de l'écran d'accueil
- Le bouton **"Mood"** de la home page (pour déclencher le questionnaire en tant que patient)

### Service de récupération :
```dart
// lib/core/services/notification_service.dart
final response = await http.get(
  Uri.parse('${ApiConstants.baseUrl}/v1/notifications'),
  headers: {'Authorization': 'Bearer $token'},
);
```

---

## 🗄️ Schéma de la base de données

### Table `notifications` :
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT PK | Identifiant |
| `title` | VARCHAR | Titre de la notification |
| `content` | VARCHAR | Corps du message |
| `type` | VARCHAR | `RISK_ALERT`, `SYSTEM`, etc. |
| `is_read` | BOOLEAN | Lu ou non (default: false) |
| `created_at` | TIMESTAMP | Date de création |
| `user_id` | BIGINT FK | → `users.id` (membre de famille) |

### Lien Patient ↔ Famille (`family_members`) :
| Colonne | Description |
|---------|-------------|
| `user_id` | ID du membre de famille (PK) |
| `patient_id` | ID du patient lié |
| `referral_key` | Code de parrainage utilisé pour l'inscription |

---

## 🔁 Checklist de lancement (ordre à respecter)

```
[ ] 1. Lancer PostgreSQL
[ ] 2. Lancer Spring Boot (pim_spring_app)
[ ] 3. Lancer le ML Service : py ml_service.py --port 8001
[ ] 4. Lancer n8n : npx n8n start
[ ] 5. Lancer Ngrok : ngrok http 5678
[ ] 6. Vérifier que le workflow n8n est "Published"
[ ] 7. Lancer l'app Flutter (téléphone physique ou émulateur)
```

---

## 🐛 Dépannage courant

| Symptôme | Cause probable | Solution |
|----------|---------------|----------|
| ML Service → 500 Internal Error | Données avec emojis | ✅ Déjà corrigé dans `ml_service.py` |
| n8n → "Connection refused" (ML API) | ML Service pas encore démarré | Attendre le message `Application startup complete` |
| n8n → "Connection refused" (Spring) | Mauvaise URL (localhost vs IP) | Utiliser l'IP locale dans le nœud `Trigger Spring Alert` |
| Spring → 403 Forbidden | Endpoint non configuré en public | Vérifier `SecurityConfig.java` |
| Flutter → Liste vide malgré notifs en DB | Sérialisation JSON du champ `user` | ✅ Déjà corrigé avec `@JsonIgnore` |
| Notif va au mauvais utilisateur | Requête JPA avec héritage (`JOINED`) | ✅ Déjà corrigé avec `findByPatientId` JPQL |
| Ngrok → ERR_CONNECTION_REFUSED | Ngrok non démarré ou redémarré | Relancer ngrok et vérifier le dashboard sur `localhost:4040` |

---

## 📞 Configuration des comptes de test

Pour tester la fonctionnalité de bout en bout :

1. **Compte Patient** : Connectez-vous avec un compte Rôle `PATIENT`
2. **Déclencher** : Appuyez sur le bouton **"Mood"** sur la home page → remplissez le questionnaire avec des valeurs à haut risque (Humeur: 1, Stress: 5)
3. **Compte Famille** : Connectez-vous avec le compte Rôle `FAMILY_MEMBER` lié au même patient (via le même `referral_key`)
4. **Vérifier** : Ouvrez la section Notifications — une alerte de risque doit apparaître

> Le lien Patient ↔ Famille se crée lors de l'inscription du membre de famille avec le `referral_key` du patient.

---

*Document généré le 27 Février 2026 — HopeUp Team*
