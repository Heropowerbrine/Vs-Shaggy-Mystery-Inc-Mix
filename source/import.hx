import Paths;

//Mobile Controls
//import mobile.flixel.FlxHitbox;
//import mobile.flixel.FlxVirtualPad;
//import mobile.flixel.input.FlxMobileInputID;
import mobile.backend.SUtil;
import mobile.backend.MobileScaleMode;
 
//Android
#if android
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.BatteryManager as AndroidBatteryManager;
#end
