Shader "Unlit/Healthbar" {
    Properties {
        [NoScaleOffset]_tex ("Texture", 2D) = "white" {}
        _hp ("hp", Range(0,1)) = .5
        _edgeSize ("edge size", Range(0,.5)) = .1
    }
    SubShader {
        Tags { "RenderType"="Transparent"
            "Queue"="Transparent" }

        ZWrite Off
        //Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            #define TAU 6.283185

            float _hp;
            float _edgeSize;
            sampler2D _tex;

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

            float Clamp (float min, float max, float t) {
                float tooLow = t < min;
                float tooHigh = max < t;
                return lerp (lerp(t, min, tooLow), max, tooHigh);
            }

            fixed4 frag (v2f i) : SV_Target {
                float4 red = float4(1, 0, 0, 1);
                float4 green = float4 (0, 1, 0, 1);
                float4 white = float4(1, 1, 1, 1);
                
                fixed4 col = tex2D(_tex, float2(_hp, i.uv.y));
                
                float4 flash = cos(_Time.y * TAU);
                flash *= flash;
                flash *= flash > 0;
                float4 flashingCol = lerp(col, white, flash);
                
                float4 ifLow = _hp < .2;
                col = lerp(col, flashingCol, ifLow);
                
                float4 mask = i.uv.x < _hp;
                col *= mask;
                
                //float4 isInBorder = i.uv.x < .01 || i.uv.x > .99 || i.uv.y < .1 || i.uv.y > .9;
                //col = lerp (col, red, isInBorder);

                return col;

                float2 closestSegmentPoint = float2(
                    Clamp(_edgeSize, 1-_edgeSize, i.uv.x),
                    Clamp(_edgeSize, 1-_edgeSize, i.uv.y));
                float distanceToSegment = length(closestSegmentPoint - i.uv);

                //float4 radial = saturate(1 - length(i.uv * 2 - 1)) > .1;
                //return float4(closestSegmentPoint, 0, 1) ;
                //return float4(i.uv, 0, 1);

                
                return distanceToSegment < _edgeSize;
            }
            ENDCG
        }
    }
}
