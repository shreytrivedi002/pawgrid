package com.pawgrid.pawgrid

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.SoundPool
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var feedback: FeedbackAudio? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        feedback = FeedbackAudio(this, flutterEngine)
    }
    override fun onResume() { super.onResume(); feedback?.active = true }
    override fun onPause() { feedback?.active = false; feedback?.stop(); super.onPause() }
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        feedback?.dispose(); feedback = null; super.cleanUpFlutterEngine(flutterEngine)
    }
}

private class FeedbackAudio(private val context: Context, engine: FlutterEngine) {
    var active = false
    private val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "pawgrid/feedback")
    private val pool = SoundPool.Builder().setMaxStreams(4).setAudioAttributes(
        AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build()).build()
    private val ids = mutableMapOf<String, Int>()
    private val loaded = mutableSetOf<Int>()
    private val streams = mutableListOf<Int>()
    private val manager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    init {
        pool.setOnLoadCompleteListener { _, id, status -> if (status == 0) loaded.add(id) }
        for (cue in listOf("mark", "erase", "place", "swipe", "undo", "warning", "hint", "win")) {
            try {
                val key = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset("assets/audio/$cue.wav")
                context.assets.openFd(key).use { ids[cue] = pool.load(it, 1) }
            } catch (_: Exception) { /* Optional audio failure is non-fatal. */ }
        }
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "prepare" -> result.success(mapOf("loaded" to ids.filterValues { loaded.contains(it) }.keys.toList(), "muted" to muted(), "active" to active, "voices" to streams.size))
                "play" -> {
                    val id = ids[call.argument<String>("cue")]
                    val volume = (call.argument<Number>("volume")?.toFloat() ?: 0.7f).coerceIn(0f, 1f) * 0.65f
                    if (!active || muted() || id == null || !loaded.contains(id) || volume <= 0f) {
                        result.success(false)
                    } else {
                        if (streams.size >= 4) pool.stop(streams.removeAt(0))
                        val stream = pool.play(id, volume, volume, 1, 0, 1f)
                        if (stream != 0) streams.add(stream)
                        result.success(stream != 0)
                    }
                }
                "stop" -> { stop(); result.success(null) }
                else -> result.notImplemented()
            }
        }
    }
    private fun muted() = manager.ringerMode != AudioManager.RINGER_MODE_NORMAL || manager.getStreamVolume(AudioManager.STREAM_MUSIC) == 0
    fun stop() { streams.forEach { pool.stop(it) }; streams.clear() }
    fun dispose() { stop(); channel.setMethodCallHandler(null); pool.release() }
}
