package com.dada.coloros.angle

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.LocalOverscrollFactory
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.dada.coloros.angle.ui.components.CouiCard
import com.dada.coloros.angle.ui.components.CouiDivider
import com.dada.coloros.angle.ui.components.CouiRow
import com.dada.coloros.angle.ui.components.CouiRowPosition
import com.dada.coloros.angle.ui.components.CouiSmallTitle
import com.dada.coloros.angle.ui.components.CouiSwitchRow
import com.dada.coloros.angle.ui.components.CouiTopAppBar
import com.dada.coloros.angle.ui.components.CouiOverscrollFactory
import com.dada.coloros.angle.ui.components.couiRowPositionOf
import com.dada.coloros.angle.ui.theme.CouiTheme
import com.kyant.backdrop.backdrops.layerBackdrop
import com.kyant.backdrop.backdrops.rememberLayerBackdrop
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

private data class AppEntry(
    val packageName: String,
    val label: String,
    val isSystem: Boolean,
)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            CouiTheme {
                AngleDriverScreen(onBack = { finish() })
            }
        }
    }
}

private const val KEY_ANGLE_PKGS = "angle_gl_driver_selection_pkgs"
private const val KEY_ANGLE_VALS = "angle_gl_driver_selection_values"

private fun readAngleMap(cr: android.content.ContentResolver): Map<String, String> {
    val pkgs = Settings.Global.getString(cr, KEY_ANGLE_PKGS)
        ?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }.orEmpty()
    val vals = Settings.Global.getString(cr, KEY_ANGLE_VALS)
        ?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }.orEmpty()
    val out = LinkedHashMap<String, String>()
    for (i in pkgs.indices) {
        val v = vals.getOrElse(i) { "default" }
        if (v == "angle") out[pkgs[i]] = "angle"
    }
    return out
}

private fun writeAngleMap(cr: android.content.ContentResolver, map: Map<String, String>): Boolean {
    return try {
        val pkgs = map.keys.joinToString(",")
        val vals = map.values.joinToString(",")
        Settings.Global.putString(cr, KEY_ANGLE_PKGS, pkgs)
        Settings.Global.putString(cr, KEY_ANGLE_VALS, vals)
        true
    } catch (_: SecurityException) {
        false
    }
}

@Composable
private fun AngleDriverScreen(onBack: () -> Unit) {
    val colors = CouiTheme.colors
    val context = LocalContext.current
    val statusBarTop = WindowInsets.statusBars.asPaddingValues().calculateTopPadding()
    val backdrop = rememberLayerBackdrop()

    var showSystemApps by remember { mutableStateOf(false) }
    var allApps by remember { mutableStateOf<List<AppEntry>>(emptyList()) }
    var angleEnabled by remember { mutableStateOf<Set<String>>(emptySet()) }
    var loaded by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        val cr = context.contentResolver
        val initialMap = withContext(Dispatchers.IO) { readAngleMap(cr) }
        angleEnabled = initialMap.keys
        val pm = context.packageManager
        val list = withContext(Dispatchers.IO) {
            pm.getInstalledApplications(PackageManager.MATCH_ALL)
                .map { ai ->
                    val isSys = (ai.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                    val label = runCatching { pm.getApplicationLabel(ai).toString() }
                        .getOrDefault(ai.packageName)
                    AppEntry(ai.packageName, label, isSys)
                }
                .sortedWith(compareBy<AppEntry> { it.label.lowercase() }.thenBy { it.packageName })
        }
        allApps = list
        loaded = true
    }

    val visibleApps = remember(allApps, showSystemApps) {
        if (showSystemApps) allApps else allApps.filter { !it.isSystem }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.surface),
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .layerBackdrop(backdrop)
                .background(colors.surface),
        ) {
            CompositionLocalProvider(LocalOverscrollFactory provides CouiOverscrollFactory) {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .navigationBarsPadding(),
                    contentPadding = PaddingValues(
                        start = 16.dp,
                        end = 16.dp,
                        top = statusBarTop + 68.dp,
                        bottom = 28.dp,
                    ),
                ) {
                    item(key = "filter_card") {
                        CouiCard {
                            CouiSwitchRow(
                                checked = showSystemApps,
                                position = CouiRowPosition.Full,
                                onCheckedChange = { showSystemApps = it },
                            ) {
                                Text(
                                    text = "Show system applications",
                                    style = CouiTheme.typography.rowTitle,
                                    color = colors.onSurface,
                                )
                                Text(
                                    text = "Switch OpenGL apps to ANGLE (Vulkan)",
                                    style = CouiTheme.typography.summary,
                                    color = colors.onSurfaceVariantSummary,
                                    modifier = Modifier.padding(top = 2.dp),
                                )
                            }
                        }
                    }

                    item(key = "apps_header") {
                        Spacer(modifier = Modifier.height(8.dp))
                        CouiSmallTitle(text = "Applications (${visibleApps.size})")
                    }

                    if (!loaded) {
                        item(key = "loading") {
                            CouiCard {
                                CouiRow(position = CouiRowPosition.Full) {
                                    Text(
                                        text = "Loading applications…",
                                        style = CouiTheme.typography.rowTitle,
                                        color = colors.onSurfaceVariantSummary,
                                    )
                                }
                            }
                        }
                    } else {
                        item(key = "apps_card") {
                            CouiCard {
                                visibleApps.forEachIndexed { idx, app ->
                                    if (idx > 0) CouiDivider()
                                    val isAngle = angleEnabled.contains(app.packageName)
                                    CouiSwitchRow(
                                        checked = isAngle,
                                        position = couiRowPositionOf(idx, visibleApps.size),
                                        onCheckedChange = { checked ->
                                            val next = LinkedHashMap<String, String>()
                                            angleEnabled.forEach { next[it] = "angle" }
                                            if (checked) next[app.packageName] = "angle" else next.remove(app.packageName)
                                            if (writeAngleMap(context.contentResolver, next)) {
                                                angleEnabled = next.keys.toSet()
                                            } else {
                                                Toast.makeText(
                                                    context,
                                                    "Requires privileged permission",
                                                    Toast.LENGTH_SHORT,
                                                ).show()
                                            }
                                        },
                                    ) {
                                        Text(
                                            text = app.label,
                                            style = CouiTheme.typography.rowTitle,
                                            color = colors.onSurface,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis,
                                        )
                                        Text(
                                            text = if (isAngle) "${app.packageName} • ANGLE (Vulkan)" else app.packageName,
                                            style = CouiTheme.typography.summary,
                                            color = if (isAngle) colors.primary else colors.onSurfaceVariantSummary,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis,
                                            modifier = Modifier.padding(top = 2.dp),
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        CouiTopAppBar(
            title = "ANGLE graphics driver",
            onBack = onBack,
            backdrop = backdrop,
        )
    }
}
