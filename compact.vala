//[Adriac:Sdx.Utils::File:SdxUtilsFile:sdx_utils_file]
/* ******************************************************************************
 * Copyright 2017 darkoverlordofdata.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
namespace Sdx.Utils {

	public const string PathSeparator  = "/";
	public const char PathSeparatorChar  = '/';
	/**
	 * Simple File handler
	 * 
	 */
		[Compact, CCode (ref_function = "sdx_utils_file_retain", unref_function = "sdx_utils_file_release")]
		public class File {
			public int ref_count = 1;
			public unowned File retain() {
				GLib.AtomicInt.add (ref ref_count, 1);
				return this;
			}
			public void release() {
				if (GLib.AtomicInt.dec_and_test (ref ref_count)) this.free ();
			}
			public extern void free();
		

		//  public Posix.Stat? stat;
		public SDL.RWops _file;
		public string _path;
		public string[] _files;

		public File(string path) {
			_path = path;
    		_file = new SDL.RWops.FromFile(path, "r");
		} 

		public string getPath() {
			return _path;
		}

		/**
		 * the name is everything after the final separator
		 */
		public string getName() {
			for (var i=_path.length-1; i>0; i--)
				if (_path[i] == PathSeparatorChar)
					return _path.SubString(i+1);
			return _path;
		}

		/**
		 * the parent is everything prior to the final separator
		 */
		public string getParent() {
			var i = _path.LastIndexOf(PathSeparator);
			return i < 0 ? "" : _path.SubString(0, i);
		}

		/**
		 * check if the represented struture exists on the virtual disk
		 */
		public bool exists() {
			return _file != null;
		}

		/**
		 * is it a file?
		 */
		public bool isFile() {
			return _file != null;
		}

		/**
		 * is it a folder?
		 */
		public bool isDirectory() {
			return false;
		}

		/**
		 * get the length of the file
		 */
		public int length() {
			return _file != null ? (int)_file.size : 0;
		}
		
		/**
		 * read the contents into a string buffer
		 */
		public string read() {
			if (!exists()) return "";
			var size = (int)_file.size;
	    	var ioBuff = new char[size+2];
    
    		var stat = _file.Read((void*)ioBuff, 2, (size_t)size/2);
			var lines = "";
			lines = lines + (string)ioBuff;
			return lines;
		}
		
			/**
		 * return the list of files in the folder
		 */
		public string[] list() {
			_files = new string[0];
			return _files;
		}
	}
}
