# Linze Adaptive Icons Setup Guide

## 🎨 **Adaptive Icon Design**

Your Linze app now uses Android's adaptive icon system, which provides a modern, consistent look across different Android devices and launchers.

## 📁 **Files Created**

### **Adaptive Icon Components:**

1. **`ic_launcher_foreground.xml`** - Your wave design in light blue (`#E0F2FE`)
2. **`ic_launcher_background.xml`** - Purple gradient background matching your app theme
3. **`ic_launcher.xml`** - Main adaptive icon configuration
4. **`ic_launcher_round.xml`** - Round icon variant for supported devices
5. **`ic_launcher_foreground_alternative.xml`** - Alternative version with play button accent

## 🎯 **Design Features**

### **Foreground (Your Wave Design):**
- **Fluid wave patterns** creating a modern, streaming-inspired look
- **Light blue color** (`#E0F2FE`) providing excellent contrast against purple background
- **Layered waves** with varying opacity for depth
- **Scalable vector graphics** ensuring crisp display at all sizes

### **Background:**
- **Purple gradient** matching your app's theme colors
- **Three-tone gradient** from `#8B5CF6` to `#C084FC`
- **Subtle depth** with layered color transitions

### **Alternative Design:**
- **Enhanced version** with white waves and light blue accents
- **Play button element** subtly referencing streaming functionality
- **Better contrast** for improved visibility

## 📱 **How Adaptive Icons Work**

Android's adaptive icon system:

1. **Combines foreground and background** layers
2. **Applies device-specific masks** (circle, square, squircle, etc.)
3. **Animates between states** (static, focused, pressed)
4. **Maintains consistency** across different launchers

## 🔧 **Icon Variants**

Your app now supports:

- **Standard adaptive icon** - Works on all Android 8.0+ devices
- **Round icon** - For devices with round icon support
- **Legacy PNG icons** - Fallback for older Android versions

## 📂 **File Structure**

```
android/app/src/main/res/
├── drawable/
│   ├── ic_launcher_foreground.xml          # Your wave design
│   ├── ic_launcher_background.xml          # Purple background
│   └── ic_launcher_foreground_alternative.xml # Enhanced version
├── mipmap-anydpi-v26/
│   ├── ic_launcher.xml                     # Main adaptive icon
│   └── ic_launcher_round.xml               # Round variant
└── mipmap-*/
    └── ic_launcher.png                     # Legacy PNG icons
```

## 🎨 **Customization Options**

### **To use the alternative design:**
Edit `ic_launcher.xml` and change:
```xml
<foreground android:drawable="@drawable/ic_launcher_foreground_alternative" />
```

### **To modify colors:**
- **Foreground**: Edit `fillColor` in the vector XML files
- **Background**: Modify the gradient colors in `ic_launcher_background.xml`

### **To adjust wave design:**
- Edit the `pathData` attributes in the foreground XML files
- Use vector graphics tools like Inkscape or Adobe Illustrator

## 🚀 **Testing Your Icons**

1. **Build and install:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

2. **Check on device:**
   - Install APK on Android 8.0+ device
   - Verify adaptive icon appears correctly
   - Test different launchers (Pixel Launcher, Nova Launcher, etc.)
   - Check both static and animated states

3. **Verify mask compatibility:**
   - Icon should look good in circle, square, and squircle masks
   - Important elements should stay within the safe zone (66dp circle)

## 🎯 **Safe Zone Guidelines**

For adaptive icons, keep important design elements within:
- **66dp circle** in the center of the 108dp canvas
- **Foreground elements** should be within this safe zone
- **Background** can extend to the full 108dp canvas

## 🔄 **Switching Between Designs**

You can easily switch between the original wave design and the enhanced version:

1. **Original waves only:**
   ```xml
   <foreground android:drawable="@drawable/ic_launcher_foreground" />
   ```

2. **Enhanced with play button:**
   ```xml
   <foreground android:drawable="@drawable/ic_launcher_foreground_alternative" />
   ```

## 📱 **Device Compatibility**

- **Android 8.0+**: Full adaptive icon support
- **Android 7.1 and below**: Falls back to PNG icons
- **Different launchers**: Each applies its own mask style

## 🎨 **Design Philosophy**

Your wave-based design perfectly represents:
- **Streaming content** - Fluid, dynamic waves
- **Anime theme** - Modern, artistic aesthetic
- **App identity** - Unique and memorable
- **Brand consistency** - Matches your purple theme

The light blue waves against the purple background create excellent contrast while maintaining the anime streaming aesthetic of your Linze app.
