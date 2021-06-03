Shader "Unlit/Healthbar" {
    Properties {
        [NoScaleOffset] _tex ("Texture", 2D) = "white" {}
        _hp ("hp", Range(0,1)) = .5
        _roundSize ("round size", Range(0.0001,.5)) = .1
        _width ("width", Range(0,1)) = 1
        _height ("height", Range(0,1)) = 1
        _edgeSize ("edge size", Range(0.0001,.5)) = .1
        _edgeColor ("edge color", Color) = (1,1,1,1)
        _maxHp ("maxHp", float) = 10
        _gapWidth ("gap width", Range(0, .2)) = .05
        _hpPerChunk ("hpPerChunk", float) = 10
        _gapColor ("gap color", Color) = (1,1,1,1)
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
            float _hp;
            float _roundSize;
            sampler2D _tex;
            float _width;
            float _height;
            float _edgeSize;
            float4 _edgeColor;
            float _gapWidth;
            float _hpPerChunk;
            float4 _gapColor;

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
                float4 red = float4(1, 0, 0, 1);
                float4 green = float4 (0, 1, 0, 1);
                float4 white = float4(1, 1, 1, 1);

                _roundSize *= min(_width, _height);
                _edgeSize = lerp(0, min(_width, _height)/2, _edgeSize);

                //color
                fixed4 col = tex2D(_tex, float2(_hp, i.uv.y));

                //hp chunks
                float amountOfChunks = _maxHp / _hpPerChunk;
                float amountOfGaps = floor(amountOfChunks - 1);
                float chunkWidth = (1 - amountOfGaps * _gapWidth)/amountOfChunks;
                float inChunk = i.uv.x % (chunkWidth + _gapWidth) < chunkWidth;
                col = lerp(_gapColor, col, inChunk);

                //flashing
                float4 flash = cos(_Time.y * TAU);
                flash *= flash;
                flash *= flash > 0;
                float4 flashingCol = lerp(col, white, flash);
                col = lerp(col, flashingCol, _hp < .2);

                //hp mask
                float4 hpMask = i.uv.x < lerp(.5 - _width/2 + _edgeSize, .5 + _width/2 - _edgeSize, _hp);
                col *= hpMask;

                //rounded edges
                float2 closestSegmentPoint = float2(
                    clamp(.5 - _width/2 + _roundSize, .5 + _width/2 - _roundSize, i.uv.x),
                    clamp(.5 - _height/2 + _roundSize, .5 + _height/2 - _roundSize, i.uv.y));
                float distance = length(closestSegmentPoint - i.uv);
                float roundedMask = distance < _roundSize;
                col *= roundedMask;

                //outline
                float edgeMask = roundedMask * (distance > _roundSize - _edgeSize);
                col = lerp(col, _edgeColor, edgeMask);

                return col;
            }
            ENDCG
        }
    }
}
