Shader "Unlit/Healthbar" {
    Properties {
        [Space]
        _currentHp ("currentHp", float) = 10
        _maxHp ("maxHp", float) = 10
        
        [Space] [Space] [Space]
        [NoScaleOffset] _tex ("Texture", 2D) = "white" {}
        _bgColor ("bg color", Color) = (1,1,1,1)
        _roundSize ("round size", Range(0.0001,.5)) = .1
        _width ("width", Range(0,1)) = 1
        _height ("height", Range(0,1)) = 1
        _edgeSize ("edge size", Range(0.0001,.5)) = .1
        _edgeColor ("edge color", Color) = (1,1,1,1)
        
        [Space] [Space] [Space]
        _durationBetweenFlashes ("duration between flashes", Range(0,5)) = 0
        _flashDuration ("flash duration", Range(0,5)) = .5
        _flashColor ("flash color", Color) = (1,1,1,1)
        
        [Space] [Space] [Space]
        _gapWidth ("gap width", Range(0, .02)) = .01
        _hpPerChunk ("hp per chunk", float) = 10
        _gapColor ("gap color", Color) = (1,1,1,1)
        
        [Space] [Space] [Space]
        _smallGapWidth ("small gap width", Range(0, .02)) = .01
        _hpPerSmallChunk ("hp per small chunk", float) = 10
    }
    SubShader {
        Tags { "RenderType"="Transparent"
            "Queue"="Transparent" }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            #define TAU 6.283185

            float _maxHp;
            float _currentHp;
            float _roundSize;
            sampler2D _tex;
            float4 _bgColor;
            float _width;
            float _height;
            float _edgeSize;
            float4 _edgeColor;
            float _gapWidth;
            float _hpPerChunk;
            float _smallGapWidth;
            float _hpPerSmallChunk;
            float4 _gapColor;
            float _durationBetweenFlashes;
            float _flashDuration;
            float4 _flashColor;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float prel (float a, float b, float t) {
                return (t-a)/(b-a);
            }

            float remap (float a, float b, float t, float newA, float newB) {
                return lerp(newA, newB, prel(a, b, t));
            }

            v2f vert (appdata v) {
                v2f o;
                
                float _hp = _currentHp / _maxHp;
                
                v.vertex.z += sin(frac(_Time.y + v.uv.x) * TAU) / 10;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float clamp (float min, float max, float t) {
                float tooLow = t < min;
                float tooHigh = max < t;
                return lerp (lerp(t, min, tooLow), max, tooHigh);
            }

            fixed4 frag (v2f i) : SV_Target {         
                _roundSize *= min(_width, _height);
                _edgeSize = lerp(0, min(_width, _height)/2, _edgeSize);
                
                float _hp = _currentHp / _maxHp;
                float localx = prel(.5 - _width/2 + _edgeSize, .5 + _width/2 - _edgeSize, i.uv.x);

                //color
                fixed4 col = tex2D(_tex, float2(_hp, i.uv.y));

                //hp chunks
                float amountOfChunks = _maxHp / _hpPerChunk;
                float amountOfGaps = floor(amountOfChunks - 1);
                float chunkWidth = (1 - amountOfGaps * _gapWidth)/amountOfChunks;
                float inChunk = localx % (chunkWidth + _gapWidth/_width) < chunkWidth;
                col = lerp(_gapColor, col, inChunk);

                //small hp chunks
                float amountOfSmallChunks = _maxHp / _hpPerSmallChunk;
                float amountOfSmallGaps = floor(amountOfSmallChunks - 1);
                float smallChunkWidth = (1 - amountOfSmallGaps * _smallGapWidth/_width)/amountOfSmallChunks;
                float inSmallChunk = localx % (smallChunkWidth + _smallGapWidth/_width) < smallChunkWidth;
                col = lerp(_gapColor, col, inSmallChunk);

                //flashing
                float flashProgress = _Time.y % (_durationBetweenFlashes + _flashDuration);
                float flash =  lerp(0, sin(flashProgress/_flashDuration * TAU/2), flashProgress < _flashDuration);
                flash *= flash;
                flash *= flash > 0;
                float4 lerpedFlash = lerp(col, _flashColor, flash);
                col = lerp(col, lerpedFlash, _hp < .2);

                //hp mask
                float4 hpMask = i.uv.x < lerp(.5 - _width/2 + _edgeSize, .5 + _width/2 - _edgeSize, _hp);
                col = lerp(_bgColor, col, hpMask);

                //rounded edges
                float2 closestSegmentPoint = float2(
                    clamp(.5 - _width/2 + _roundSize, .5 + _width/2 - _roundSize, i.uv.x),
                    clamp(.5 - _height/2 + _roundSize, .5 + _height/2 - _roundSize, i.uv.y));
                float distance = length(closestSegmentPoint - i.uv);
                float roundedMask = distance < _roundSize;
                col *= roundedMask;

                //outline
                float edgeMask = roundedMask * (distance > max(0, _roundSize - _edgeSize));
                col = lerp(col, _edgeColor, edgeMask);

                return col;
            }
            ENDCG
        }
    }
}
