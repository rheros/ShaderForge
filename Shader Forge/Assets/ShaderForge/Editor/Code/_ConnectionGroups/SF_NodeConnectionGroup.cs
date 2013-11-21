using UnityEngine;
using System.Collections;


namespace ShaderForge {

	// Used to detect types based on input
	[System.Serializable]
	public class SF_NodeConnectionGroup : ScriptableObject {


		public SF_NodeConnection output;
		public SF_NodeConnection[] inputs;



		public void OnEnable() {
			base.hideFlags = HideFlags.HideAndDontSave;
		}


		public SF_NodeConnectionGroup() {
			// Empty
		}


		/*
		public void Initialize( SF_NodeConnection output, params SF_NodeConnection[] inputs ) {
			this.output = output;
			this.inputs = inputs;
		}*/


		public virtual void Refresh() {
			// Override
		}

		public void AssignToEmptyInputs( ValueType vt ) {
			foreach( SF_NodeConnection nc in inputs ) {
				if( !nc.IsConnected() )
					nc.valueType = vt;
			}
		}

		public bool InputsMissing() {
			foreach( SF_NodeConnection nc in inputs ) {
				if( !nc.IsConnected() )
					return true;
			}
			return false;
		}

		public void ResetValueTypes() {
			output.ResetValueType();
			foreach( SF_NodeConnection nc in inputs ) {
				nc.ResetValueType();
			}
		}

		public bool NoInputsConnected() {
			foreach( SF_NodeConnection nc in inputs ) {
				if( nc.IsConnected() )
					return false;
			}
			return true;
		}

		public static bool IsVectorType( ValueType vTinput ) {
			if( vTinput == ValueType.VTv1 )
				return true;
			if( vTinput == ValueType.VTv2 )
				return true;
			if( vTinput == ValueType.VTv3 )
				return true;
			if( vTinput == ValueType.VTv4 )
				return true;
			return false;
		}


	}
}