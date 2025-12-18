# 🎙️ Guide d'Utilisation - EduBot Vocal

## ✅ Installation Terminée !

Toutes les dépendances sont installées :
- ✅ OpenAI (Whisper + TTS)
- ✅ SoundDevice (enregistrement)
- ✅ SciPy (traitement audio)
- ✅ Pygame (lecture audio)

---

## 🚀 Comment Utiliser

### Lancer le Chatbot Vocal

```powershell
python chatbot_vocal.py
```

### Déroulement d'une Session

1. **Menu s'affiche**
   ```
   OPTIONS:
     1. 🎤 Poser une question vocale
     2. ❌ Quitter
   ```

2. **Tapez `1` et appuyez sur Entrée**

3. **🎙️ PARLEZ votre question** (5 secondes)
   - Exemples :
     - "Explique-moi les classes en Python"
     - "Comment fonctionne l'héritage en Java ?"
     - "Qu'est-ce qu'une boucle for ?"

4. **⏳ Attendez le traitement** (~5-10 secondes):
   - 🔄 Transcription (Whisper)
   - 🤔 Recherche dans les cours
   - 🔊 Génération audio (TTS)

5. **📖 Réponse affichée à l'écran**

6. **🔊 Réponse lue à voix haute automatiquement**

7. **Répétez ou quittez** (tapez 2)

---

## 🎯 Exemples de Questions à Tester

### Java
- "Explique-moi la programmation orientée objet en Java"
- "Comment créer une classe en Java ?"
- "Qu'est-ce que l'encapsulation ?"

### Python  
- "Comment fonctionne l'héritage en Python ?"
- "Quelle est la différence entre liste et tuple ?"
- "Explique-moi les méthodes en Python"

---

## ⚠️ Recommandations

### Pour un bon enregistrement:
- 🎤 **Microphone fonctionnel** requis
- 🔇 **Environnement calme** (éviter le bruit)
- 🗣️ **Parlez clairement** et à vitesse normale
- ⏱️ **5 secondes** pour formuler votre question

### Astuces:
- Formulez des questions courtes et précises
- Attendez le "bip" ou l'indication avant de parler
- Ne parlez pas trop vite

---

## 🔧 Paramètres Modifiables

Dans `chatbot_vocal.py`, vous pouvez changer:

```python
DURATION = 5  # Durée d'enregistrement (secondes)
```

Augmentez à 10 pour des questions plus longues.

**Voix TTS** (ligne ~100):
```python
voice="nova"  # Options: alloy, echo, fable, onyx, nova, shimmer
```

---

## 💰 Coûts par Question Vocale

- **Whisper (STT):** ~$0.0005 par question
-  **TTS:** ~$0.0075 par réponse
- **Total:** ~$0.008 par interaction complète

**Vos $5-18 de crédits = 600-2000 questions vocales !**

---

## 🐛 Dépannage

### "Erreur d'enregistrement"
- Vérifiez que votre microphone est branché
- Autorisez l'accès au micro dans Windows

### "Erreur de transcription"
- Vérifiez votre connexion Internet
- Vérifiez que votre clé OpenAI est valide

### Pas de son lors de la lecture
- Vérifiez que vos haut-parleurs sont allumés
- Vérifiez le volume Windows

---

## 🎓 Prêt à Tester !

Lancez simplement :
```powershell
python chatbot_vocal.py
```

**Et profitez de votre assistant pédagogique vocal ! 🚀**
