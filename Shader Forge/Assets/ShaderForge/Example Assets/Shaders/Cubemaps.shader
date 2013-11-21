// Shader created with Shader Forge Alpha 0.15 
// Shader Forge (c) Joachim 'Acegikmo' Holmer
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:0.15;sub:START;pass:START;ps:lgpr:1,nrmq:1,limd:3,blpr:0,bsrc:3,bdst:7,culm:0,dpts:2,wrdp:True,uamb:True,ufog:True,aust:True,igpj:False,qofs:0,lico:1,qpre:1,flbk:,rntp:1,lmpd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True;n:type:ShaderForge.SFN_Final,id:0,x:32953,y:32692|spec-2-R,normal-4-RGB,emission-5-OUT;n:type:ShaderForge.SFN_Cubemap,id:1,x:33410,y:33012,ptlb:Cubemap,cube:f466cf7415226e046b096197eb7341aa,pvfc:1;n:type:ShaderForge.SFN_Tex2d,id:2,x:33221,y:32649,ptlb:Specular,tex:26c22711225093d47bd4f1294ca52131;n:type:ShaderForge.SFN_Tex2d,id:4,x:33221,y:32796,ptlb:Normal,tex:80286949e259c2d44876306923857245;n:type:ShaderForge.SFN_Multiply,id:5,x:33221,y:32926|A-10-OUT,B-1-RGB;n:type:ShaderForge.SFN_NormalVector,id:6,x:33969,y:32781,pt:False;n:type:ShaderForge.SFN_ComponentMask,id:8,x:33776,y:32781,cc1:1,cc2:-1,cc3:-1,cc4:-1|IN-6-OUT;n:type:ShaderForge.SFN_Add,id:10,x:33410,y:32856|A-12-OUT,B-13-OUT;n:type:ShaderForge.SFN_Vector1,id:11,x:33776,y:32918,v1:0.4;n:type:ShaderForge.SFN_Multiply,id:12,x:33589,y:32791|A-8-OUT,B-11-OUT;n:type:ShaderForge.SFN_OneMinus,id:13,x:33589,y:32918|IN-11-OUT;proporder:1-2-4;pass:END;sub:END;*/

Shader "Shader Forge/Examples/Cubemaps" {
    Properties {
        _Cubemap ("Cubemap", Cube) = "_Skybox" {}
        _Specular ("Specular", 2D) = "white" {}
        _Normal ("Normal", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Tags {
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers gles xbox360 ps3 flash 
            #pragma target 3.0
            #pragma glsl
            uniform float4 _LightColor0;
            uniform samplerCUBE _Cubemap;
            uniform sampler2D _Specular;
            uniform sampler2D _Normal;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 uv0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 binormalDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normalDir = mul(float4(v.normal,0), _World2Object).xyz;
                o.tangentDir = normalize( mul( _Object2World, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.binormalDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                float3x3 tangentTransform = float3x3( i.tangentDir, i.binormalDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalLocal = UnpackNormal(tex2D(_Normal,i.uv0.xy)).rgb;
                float3 normalDirection = normalize( mul( normalLocal, tangentTransform ) );
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
//////// DEBUG - Lighting()
                float3 attenuation = LIGHT_ATTENUATION(i) * _LightColor0.xyz;
//////// DEBUG - CalcDiffuse()
                float3 diffuse = max( 0.0, dot(normalDirection,lightDirection )) * attenuation;
//////// DEBUG - CalcEmissive()
                float node_11 = 0.4;
                float3 emissive = (((i.normalDir.g*node_11)+(1.0 - node_11))*texCUBE(_Cubemap,viewReflectDirection).rgb);
                float gloss = exp2(10*10.0+1.0);
//////// DEBUG - CalcSpecular()
                float4 _Specular_var = tex2D(_Specular,i.uv0.xy);
                float3 specular = attenuation * float3(_Specular_var.r,_Specular_var.r,_Specular_var.r) * pow(max(0,dot(reflect(-lightDirection, normalDirection),viewDirection)),gloss);
                float3 lightFinal = diffuse;
                return fixed4(lightFinal * float3(0,0,0) + specular + emissive,1);
                return fixed4(lightFinal * float3(0,0,0),1);
            }
            ENDCG
        }
        Pass {
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma exclude_renderers gles xbox360 ps3 flash 
            #pragma target 3.0
            #pragma glsl
            uniform float4 _LightColor0;
            uniform samplerCUBE _Cubemap;
            uniform sampler2D _Specular;
            uniform sampler2D _Normal;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 uv0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 binormalDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normalDir = mul(float4(v.normal,0), _World2Object).xyz;
                o.tangentDir = normalize( mul( _Object2World, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.binormalDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                float3x3 tangentTransform = float3x3( i.tangentDir, i.binormalDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalLocal = UnpackNormal(tex2D(_Normal,i.uv0.xy)).rgb;
                float3 normalDirection = normalize( mul( normalLocal, tangentTransform ) );
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
//////// DEBUG - Lighting()
                float3 attenuation = LIGHT_ATTENUATION(i) * _LightColor0.xyz;
//////// DEBUG - CalcDiffuse()
                float3 diffuse = max( 0.0, dot(normalDirection,lightDirection )) * attenuation;
                float gloss = exp2(10*10.0+1.0);
//////// DEBUG - CalcSpecular()
                float4 _Specular_var = tex2D(_Specular,i.uv0.xy);
                float3 specular = attenuation * float3(_Specular_var.r,_Specular_var.r,_Specular_var.r) * pow(max(0,dot(reflect(-lightDirection, normalDirection),viewDirection)),gloss);
                float3 lightFinal = diffuse;
                return fixed4(lightFinal * float3(0,0,0) + specular,1);
                return fixed4(lightFinal * float3(0,0,0),1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}