import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { makeRoutePath } from '~/logic/lib/util';

export class CommentsPagination extends Component {
  render() {
    const props = this.props;

    const prevPage = (Number(props.commentPage) - 1);
    const nextPage = (Number(props.commentPage) + 1);

    const prevDisplay = ((Number(props.commentPage) > 0))
    ? 'dib'
    : 'dn';

    const nextDisplay = ((Number(props.commentPage) + 1) < Number(props.total))
    ? 'dib'
    : 'dn';

    return (
      <div className="w-100 relative pt4 pb6">
        <Link
        className={'pb6 absolute inter f8 left-0 ' + prevDisplay}
        to={makeRoutePath(props.resourcePath, props.popout, props.linkPage, props.url, props.linkIndex, prevPage)}
        >
          &#60;- Previous Page
        </Link>
        <Link
        className={'pb6 absolute inter f8 right-0 ' + nextDisplay}
        to={makeRoutePath(props.resourcePath, props.popout, props.linkPage, props.url, props.linkIndex, nextPage)}
        >
          Next Page -&gt;
        </Link>
      </div>
    );
  }
}

export default CommentsPagination;
