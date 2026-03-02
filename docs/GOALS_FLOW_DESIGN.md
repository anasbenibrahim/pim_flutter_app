# Flow complet — Réduction d'addiction (Patient Goals)

> **Contexte** : Application HopeUp — Flow de gamification pour patients en réduction d'addiction.  
> Chaque objectif créé, suivi et validé par l'utilisateur déclenche des récompenses (XP, badges, messages motivationnels).

---

## Règles psycho / UX obligatoires (priorité)

- **Objectifs réalistes** : Pas d’objectifs trop ambitieux d’emblée
- **Progression graduelle** : Du petit (24h) au plus long (30 jours)
- **Feedback positif** : Toujours valoriser l’effort, même partiel
- **Jamais de punition forte** en cas d’échec — rappel : l’addiction implique un cerveau vulnérable ; l’app encourage et évite la culpabilisation

---

## 1. Écran « Créer un objectif »

### Titre
**Create a goal**

### Composants

| Section | Contenu |
|--------|---------|
| **Catégorie** | 3 onglets obligatoires : Time-based / Reduction-based / Alternative behavior |
| **Liste d’objectifs prédéfinis** | Affichés selon la catégorie sélectionnée |
| **Option « Custom »** | Champ(s) : valeur, durée, fréquence |
| **Indicateurs** | Difficulté (Easy / Medium / Hard), XP estimé |
| **Bouton** | « Create goal » |

### Catégories et objectifs prédéfinis

#### A) Time-based
| Objectif | Difficulté | XP |
|----------|------------|----|
| Ne pas consommer pendant 24h | Easy | 10 |
| 3 jours clean | Easy | 10 |
| 7 jours clean | Medium | 50 |
| 30 jours clean | Hard | 100 |

#### B) Reduction-based
| Objectif | Difficulté | XP |
|----------|------------|----|
| Passer de 10 cigarettes → 5 | Easy | 10 |
| Réduire temps écran 6h → 3h | Medium | 50 |
| Réduire consommation sucre | Medium | 50 |
| Custom (de X à Y) | Selon écart | 10–100 |

#### C) Alternative behavior
| Objectif | Difficulté | XP |
|----------|------------|----|
| Faire 20 min sport | Easy | 10 |
| Lire 15 min au lieu de consommer | Easy | 10 |
| Méditer 10 min | Easy | 10 |
| Custom ( activité + durée ) | Easy–Medium | 10–50 |

### Wireframe textuel

```
┌─────────────────────────────────────┐
│ ← Create a goal                     │
├─────────────────────────────────────┤
│ [Time-based] [Reduction] [Alternative]│
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ ○ 24h clean      Easy    +10 XP │ │
│ │ ○ 3 days clean   Easy    +10 XP │ │
│ │ ○ 7 days clean   Medium  +50 XP │ │
│ │ ○ 30 days clean  Hard   +100 XP  │ │
│ │ ○ Custom...                     │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [       Create goal       ]         │
└─────────────────────────────────────┘
```

### Actions
- Sélectionner une catégorie
- Sélectionner un objectif prédéfini ou « Custom »
- Si Custom : renseigner valeur / durée / fréquence
- Confirmer la création → événement `goalCreated`

---

## 2. Écran de suivi de l’objectif (Tracking)

### Titre
**My goal** ou **Goal progress**

### Composants

| Section | Contenu |
|--------|---------|
| **Progression** | Barre de progression OU compteur de jours OU compteur de réduction |
| **Statut** | Badge : `In progress` / `Completed` / `Failed` / `Restart` |
| **Historique journalier** | Liste simple jour par jour (optionnel : check-in quotidien) |
| **Bouton « Validate »** | Visible quand l’objectif est atteignable selon les règles |

### Wireframe textuel

```
┌─────────────────────────────────────┐
│ ← My goal                           │
├─────────────────────────────────────┤
│ 7 days clean                        │
│ ████████░░░░░░ 4/7 days   In progress│
├─────────────────────────────────────┤
│ Daily check-ins                     │
│ ✓ Day 1   ✓ Day 2   ✓ Day 3   ✓ Day 4│
│ ○ Day 5   ○ Day 6   ○ Day 7         │
├─────────────────────────────────────┤
│ [       Validate goal       ]       │
└─────────────────────────────────────┘
```

### Actions
- Consulter la progression
- Consulter l’historique
- Cliquer sur « Validate » → ouverture de la fenêtre de validation

---

## 3. Validation (confirmation utilisateur)

### Fenêtre modale / bottom sheet

**Titre** : Confirm your achievement

**Texte** : « I confirm that I have reached my goal »

**Composants**
- Checkbox ou CTA : « Yes, I did it »
- Champ optionnel : « Add a note (optional) »
- Boutons : **Cancel** | **Confirm**

### Wireframe textuel

```
┌─────────────────────────────────────┐
│ Confirm your achievement            │
├─────────────────────────────────────┤
│ I confirm that I have reached my    │
│ goal.                               │
│                                     │
│ [ Add a note (optional)          ]  │
│                                     │
│ [Cancel]          [Confirm]          │
└─────────────────────────────────────┘
```

### Actions
- **Confirm** → événement `goalValidated` → attribution des récompenses
- **Cancel** → fermeture, retour à l’écran de suivi

---

## 4. Récompenses (gamification)

### A) Système de points (XP)

| Difficulté | XP par objectif validé |
|------------|------------------------|
| Easy | +10 XP |
| Medium | +50 XP |
| Hard | +100 XP |

**Niveaux** (accès par XP cumulé)

| Level | Titre | XP requis |
|-------|-------|-----------|
| 1 | Beginner | 0 |
| 2 | Fighter | 50 |
| 3 | Warrior | 150 |
| 4 | Challenger | 300 |
| 5 | Resilient | 500 |
| 6 | Strong | 800 |
| 7 | Champion | 1 200 |
| 8 | Legend | 1 800 |
| 9 | Freedom Hero | 2 500 |
| 10 | Freedom Master | 3 500 |

### B) Badges obligatoires

| Badge | Condition | Emoji |
|-------|-----------|-------|
| First 24h Clean | Premier objectif 24h validé | 🥇 |
| 7 Days Streak | Objectif 7 jours validé | 🔥 |
| 30 Days Strong | Objectif 30 jours validé | 💎 |
| Mind Control Master | 3 objectifs « alternative behavior » validés | 🧠 |
| Reduction Pro | 2 objectifs « reduction-based » validés | 📉 |
| Consistency King | 5 objectifs validés au total | 👑 |

### C) Messages motivationnels

Affichés après chaque validation. Messages courts, positifs, non jugements.  
Exemples en fin de document.

---

## 5. Événements (analytics / state)

| Événement | Déclencheur |
|----------|-------------|
| `goalCreated` | Création d’un objectif |
| `goalTrackingViewed` | Ouverture de l’écran de suivi |
| `goalValidationRequested` | Clic sur « Validate » |
| `goalValidated` | Confirmation dans la modale |
| `goalValidationCancelled` | Annulation dans la modale |
| `xpAdded` | Attribution des XP après validation |
| `badgeUnlocked` | Déblocage d’un badge |
| `levelUp` | Passage au niveau supérieur |
| `motivationalMessageShown` | Affichage d’un message motivant |

---

## 6. Règles métier (conditions)

### XP
- XP = 10 si difficulté Easy
- XP = 50 si difficulté Medium
- XP = 100 si difficulté Hard
- XP cumulés = somme de tous les objectifs validés

### Badges
- `badgeUnlocked` si la condition du badge est remplie (voir tableau)
- Chaque badge ne se débloque qu’une fois

### Level up
- `levelUp` quand total XP ≥ seuil du niveau N+1
- Affichage d’un écran/overlay de célébration (court)

### Validation
- « Validate » activé uniquement si :
  - Objectif time-based : jours atteints ≥ objectif
  - Objectif reduction : valeur actuelle ≤ cible
  - Objectif alternative : nombre de sessions ≥ objectif

---

## 7. Messages motivationnels (10 exemples)

1. **Tu l’as fait. Chaque pas compte.**
2. **Tu es plus fort que tu ne le penses.**
3. **Chaque jour sans consommation est une victoire.**
4. **Tu construis ta liberté, une décision à la fois.**
5. **Le cerveau se répare. Tu lui donnes une chance.**
6. **Petit pas après petit pas, tu avances.**
7. **Tu as choisi la santé. Bravo.**
8. **Chaque objectif atteint prouve que tu peux.**
9. **Tu n’es pas seul. Et tu progresses.**
10. **Aujourd’hui, tu as gagné. Continuez.**

---

## 8. Intégration navigation

### Tab « Goals » dans la bottom navigation

- **Position** : Entre « Social » et « Profile » (ou après Home selon préférence)
- **Icône** : `Icons.flag_rounded` ou `Icons.emoji_events_rounded`
- **Label** : Goals
- **Page** : Hub des objectifs (liste des objectifs actifs + accès à la création)

### Structure des routes

| Route | Page |
|-------|------|
| `/goals` | GoalsHubPage (liste + résumé XP/Niveau) |
| `/goals/create` | CreateGoalPage |
| `/goals/:id` | GoalTrackingPage |
| `/goals/:id/validate` | (modale ou étape dans Tracking) |

---

## 9. Scénario utilisateur complet (étape par étape)

1. Le patient ouvre l’onglet **Goals** dans la navigation.
2. Il voit ses objectifs en cours, son niveau et ses XP.
3. Il appuie sur **Create goal**.
4. Il choisit une catégorie (ex. Time-based), sélectionne « 7 jours clean » (Medium, +50 XP).
5. Il confirme → `goalCreated`.
6. Il est redirigé vers l’écran de suivi de cet objectif.
7. Chaque jour (ou à son rythme), il peut faire un check-in. La barre de progression se met à jour.
8. Au jour 7, le bouton **Validate** devient actif.
9. Il clique sur **Validate** → fenêtre « I confirm that I have reached my goal ».
10. Il ajoute éventuellement une note, puis **Confirm**.
11. → `goalValidated` → attribution de 50 XP, vérification des badges, éventuel `levelUp`.
12. Un message motivationnel s’affiche (ex. « Tu l’as fait. Chaque pas compte. »).
13. Retour au hub Goals ou à la liste des objectifs avec le nouvel état.

---

*Document prêt pour implémentation. À adapter selon les contraintes backend et design system existant.*
